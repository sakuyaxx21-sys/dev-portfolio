#!/usr/bin/env bash
set -euo pipefail

required_env_vars=(
  AWS_REGION
  SSM_TARGET_KEY
  SSM_TARGET_VALUE
  DOCKER_IMAGE
  IMAGE_TAG
  APP_CONTAINER_NAME
  APP_ENV_FILE
  APP_PORT
)

for env_var in "${required_env_vars[@]}"; do
  if [[ -z "${!env_var:-}" ]]; then
    echo "${env_var} is required" >&2
    exit 1
  fi
done

full_image="${DOCKER_IMAGE}:${IMAGE_TAG}"
params_file="$(mktemp)"

jq -n \
  --arg image "$full_image" \
  --arg container "$APP_CONTAINER_NAME" \
  --arg env_file "$APP_ENV_FILE" \
  --arg port "$APP_PORT" \
  '{
    commands: [
      "set -euo pipefail",
      ("docker pull " + $image),
      ("docker run --rm --env-file " + $env_file + " " + $image + " alembic upgrade head"),
      ("docker stop " + $container + " || true"),
      ("docker rm " + $container + " || true"),
      ("docker run -d --name " + $container + " -p " + $port + ":8000 --env-file " + $env_file + " --restart unless-stopped " + $image),
      ("for i in $(seq 1 30); do if curl -fsS http://localhost:" + $port + "/api/v1/health >/dev/null; then exit 0; fi; sleep 5; done"),
      ("docker logs " + $container + " --tail 100"),
      "exit 1"
    ]
  }' > "$params_file"

command_id="$(
  aws ssm send-command \
    --region "$AWS_REGION" \
    --document-name "AWS-RunShellScript" \
    --targets "Key=${SSM_TARGET_KEY},Values=${SSM_TARGET_VALUE}" \
    --parameters "file://${params_file}" \
    --comment "Deploy ${full_image}" \
    --timeout-seconds "${SSM_COMMAND_TIMEOUT_SECONDS:-900}" \
    --query "Command.CommandId" \
    --output text
)"

echo "SSM command id: ${command_id}"

for _ in $(seq 1 120); do
  invocations="$(
    aws ssm list-command-invocations \
      --region "$AWS_REGION" \
      --command-id "$command_id" \
      --details \
      --output json
  )"

  invocation_count="$(jq '.CommandInvocations | length' <<< "$invocations")"

  if [[ "$invocation_count" -eq 0 ]]; then
    sleep 5
    continue
  fi

  if jq -e '
    [.CommandInvocations[].Status] |
    any(. == "Pending" or . == "InProgress" or . == "Delayed")
  ' <<< "$invocations" >/dev/null; then
    sleep 5
    continue
  fi

  if jq -e '[.CommandInvocations[].Status] | all(. == "Success")' <<< "$invocations" >/dev/null; then
    echo "Deployment command completed successfully"
    exit 0
  fi

  echo "$invocations" | jq '.CommandInvocations[] | {InstanceId, Status, StatusDetails, CommandPlugins}'
  exit 1
done

echo "Timed out waiting for SSM command ${command_id}" >&2
exit 1

## Summary

<!-- Describe the change and its purpose in 2-3 sentences -->

## Type of Change

- [ ] Bug fix (non-breaking)
- [ ] New feature / workflow (non-breaking)
- [ ] Breaking change (existing workflow behaviour changes)
- [ ] Documentation update
- [ ] Security patch

## Downstream Impact Checklist

> **Required for any change to `workflows/reusable/`**

- [ ] I have identified all repositories that consume the modified reusable workflow(s)
- [ ] I have verified backward compatibility (input parameters unchanged or new inputs have defaults)
- [ ] I have notified downstream consumers via Slack `#jol-deploys` channel
- [ ] I have tested the reusable workflow with `workflow_dispatch` in isolation

## Security

- [ ] No secrets, tokens, or credentials are committed
- [ ] TruffleHog scan passes locally (`trufflehog filesystem --directory . --fail`)
- [ ] Changes to `policies/` or `workflows/reusable/` have been reviewed by `@security-review`

## Compliance (SOC 2)

- [ ] If this change affects audit evidence collection, I have updated `scripts/audit/` accordingly
- [ ] If this change affects alerting rules, I have validated with `promtool check rules`

## Testing

- [ ] yamllint passes (`yamllint -c .yamllint.yaml .`)
- [ ] shellcheck passes for any modified `.sh` files

## Screenshots / Evidence

<!-- Attach logs, screenshots, or workflow run URLs -->

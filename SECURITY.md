# Security Policy

## Supported Versions

We provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| main    | :white_check_mark: |
| < main  | :x:                |

Currently, we only support the latest version from the `main` branch. We recommend always using the latest version of the compliance framework.

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in labrats-compliance, please report it responsibly.

### How to Report

**DO NOT** open a public GitHub issue for security vulnerabilities.

Instead, please report security issues via:

1. **GitHub Security Advisories** (preferred):
   - Go to the [Security tab](https://github.com/labrats-work/labrats-compliance/security)
   - Click "Report a vulnerability"
   - Fill out the form with details

2. **Email** (alternative):
   - Send an email to the repository maintainers
   - Include "SECURITY" in the subject line
   - Provide detailed information about the vulnerability

### What to Include

When reporting a vulnerability, please provide:

- **Description**: A clear description of the vulnerability
- **Impact**: What could an attacker do with this vulnerability?
- **Steps to reproduce**: Detailed steps to reproduce the issue
- **Affected versions**: Which versions are vulnerable?
- **Suggested fix**: If you have ideas for fixing it
- **Proof of concept**: Code or commands demonstrating the issue (if applicable)

### What to Expect

- **Acknowledgment**: We'll acknowledge receipt within 48 hours
- **Assessment**: We'll assess the vulnerability and its impact
- **Updates**: We'll keep you informed of our progress
- **Timeline**: We aim to fix critical issues within 7 days
- **Credit**: We'll credit you in the security advisory (if desired)

## Security Considerations

### GitHub App Credentials

This project uses GitHub Apps for cross-repository access. **Never commit credentials**:

- ❌ Do not commit `APP_PRIVATE_KEY`
- ❌ Do not commit `APP_ID`
- ❌ Do not commit any GitHub tokens
- ✅ Use GitHub Secrets for storing credentials
- ✅ Rotate credentials if compromised

### Compliance Check Scripts

Compliance checks run bash scripts on cloned repositories. Security concerns:

#### For Check Developers

- **Input validation**: Always validate repository paths
- **Command injection**: Never use unsanitized input in commands
- **Path traversal**: Ensure paths stay within repository bounds
- **Resource limits**: Prevent infinite loops or excessive resource use
- **Error handling**: Fail safely without exposing sensitive data

#### For Check Users

- **Trusted sources**: Only run checks from trusted sources
- **Review scripts**: Audit check scripts before running
- **Sandboxing**: Consider running checks in isolated environments
- **Permissions**: Use minimal required permissions

### GitHub API Access

The compliance framework requires GitHub API access:

- **Minimal permissions**: Request only necessary permissions
  - `Administration: read` (for 3 checks)
  - `Contents: read` (for 15 checks)
  - `Metadata: read` (automatic)
- **Token scope**: Use GitHub Apps, not personal tokens
- **Rate limiting**: Implement proper rate limit handling
- **Error handling**: Handle API errors without exposing tokens

See [API_PERMISSIONS.md](API_PERMISSIONS.md) for detailed permission requirements.

### Workflow Security

The GitHub Actions workflow has security considerations:

#### Secrets Management

- Store GitHub App credentials in GitHub Secrets
- Never log secret values
- Use `secrets` context, not environment variables for sensitive data
- Rotate secrets regularly

#### Workflow Permissions

Our workflow uses:
- `GITHUB_TOKEN`: For same-repo operations
- `GitHub App token`: For cross-repo read access

**Permissions used**:
```yaml
permissions:
  contents: write    # To commit reports
  issues: write      # To create compliance issues
```

#### Third-Party Actions

We pin all GitHub Actions to specific SHAs:
```yaml
- uses: actions/checkout@v4  # Verified action
```

#### Code Injection Prevention

- Never use unsanitized inputs in bash scripts
- Validate all inputs from GitHub event payload
- Use proper quoting in shell commands

### Clone Security

The workflow clones multiple repositories:

- **Shallow clones**: Uses `--depth 1` to minimize data transfer
- **Branch specific**: Only clones default branch
- **Read-only access**: GitHub App has read-only permissions
- **Temporary storage**: Cloned repos deleted after checks

### Issue Creation Security

When creating compliance issues:

- **Template validation**: Issue templates are validated
- **Content sanitization**: User input is sanitized
- **Rate limiting**: Prevent issue spam
- **Label verification**: Ensure labels exist before use

## Known Security Limitations

### GitHub App Permissions

The GitHub App requires `Administration: read` permission to check:
- Branch protection rules
- Repository settings
- Default branch configuration

While this is read-only, it does grant access to sensitive repository configuration. Organizations should:
- Review the app's source code
- Understand what data is accessed
- Monitor app activity via audit logs

### Local Execution

Running compliance checks locally:

- Scripts have full access to cloned repository contents
- Scripts run with your user permissions
- Malicious repositories could exploit script vulnerabilities
- Always review scripts before running on untrusted repositories

## Security Best Practices

### For Repository Maintainers

1. **Enable branch protection** on `main`
2. **Require pull request reviews**
3. **Enable security alerts** (Dependabot, code scanning)
4. **Rotate secrets regularly**
5. **Monitor access logs**
6. **Review workflow changes** carefully

### For Contributors

1. **Review code changes** before submitting
2. **Test locally** before pushing
3. **Don't commit secrets**
4. **Follow least privilege** principle
5. **Report vulnerabilities** responsibly

### For Users

1. **Review the code** before installing the GitHub App
2. **Understand permissions** being requested
3. **Monitor compliance reports** for unexpected findings
4. **Audit logs** for GitHub App activity
5. **Keep up to date** with the latest version

## Security Updates

Security updates will be:
- Released as soon as possible after discovery
- Announced via GitHub Security Advisories
- Documented in the CHANGELOG
- Tagged with security labels

Subscribe to repository notifications to stay informed.

## Responsible Disclosure

We follow responsible disclosure practices:

1. **Private reporting**: Security issues reported privately
2. **Assessment period**: Time to assess and fix (up to 90 days)
3. **Coordinated disclosure**: Public disclosure coordinated with fix
4. **Credit given**: Reporters credited (if desired)
5. **Transparency**: Security advisories published post-fix

## Questions?

For security-related questions (non-vulnerabilities):
- Open a GitHub Discussion
- Tag with "security" label
- Refer to this document

For vulnerabilities, follow the reporting process above.

## External Resources

- [GitHub Security Best Practices](https://docs.github.com/en/code-security)
- [GitHub App Security](https://docs.github.com/en/apps/creating-github-apps/about-creating-github-apps/best-practices-for-creating-a-github-app)
- [Securing GitHub Actions](https://docs.github.com/en/actions/security-guides)

---

**Last Updated**: 2025-12-06

Thank you for helping keep labrats-compliance secure!

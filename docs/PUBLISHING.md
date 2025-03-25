# Publishing Your PhD Workflow Tools

This guide will help you publish your tools to GitHub for sharing with your lab members and the wider research community.

## One-Time Setup

1. **Clone your repository locally**:
   ```bash
   git clone https://github.com/Amanpatni211/PhdWorkflowSetupTools-.git
   cd PhdWorkflowSetupTools-
   ```

2. **Copy your current tools**:
   ```bash
   # Run the copy script
   ./copy_to_repo.sh
   ```

3. **Commit and push the changes**:
   ```bash
   git add .
   git commit -m "Initial release of PhD workflow tools"
   git push origin main
   ```

## Sharing with Others

### Via GitHub

Share the repository URL with your lab members:
```
https://github.com/Amanpatni211/PhdWorkflowSetupTools-
```

They can follow the installation instructions in the README.md to set up the tools.

### Via Releases

For stable versions, create GitHub releases:

1. Go to your repository on GitHub
2. Click "Releases" in the right sidebar
3. Click "Create a new release"
4. Tag version: "v1.0.0"
5. Title: "Initial Release"
6. Description: Add notes about the features
7. Click "Publish release"

## Updating the Tools

When you make improvements to your tools:

1. Update your local tools
2. Run `./copy_to_repo.sh` to copy changes to the repository
3. Commit and push:
   ```bash
   git add .
   git commit -m "Update: description of changes"
   git push origin main
   ```

## Documentation

Keep the documentation up-to-date:

1. README.md - Main installation and overview
2. docs/user_guide.md - Detailed usage instructions
3. CONTRIBUTING.md - Guidelines for contributors

## Promotion

To get more users:

1. Share with colleagues and lab members
2. Present at lab meetings
3. Add to your publications as a methodology reference
4. Include in your research group's resources page 
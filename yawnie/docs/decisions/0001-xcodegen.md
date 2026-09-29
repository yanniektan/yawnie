# 0001: Generate the Xcode project with XcodeGen

Parallel agents editing one .pbxproj cause merge conflicts. `App/project.yml` is the source of truth, and the .xcodeproj is generated and gitignored.

# A simple module that only do dot source.
# By Import-Module this, all functions in the module will be available in the global scope.
# https://www.reddit.com/r/PowerShell/comments/1dz56cx/question_about_dot_sourcing_inside_functions/

# https://cn.x-cmd.com/start/windows
if (Test-Path "$Home\.x-cmd.root\local\data\pwsh\_index.ps1") {
    . "$Home\.x-cmd.root\local\data\pwsh\_index.ps1"
}; # boot up x-cmd.

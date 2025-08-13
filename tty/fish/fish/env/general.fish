# Add /usr/local/bin to PATH on macOS if it exists
if test (uname) = "Darwin"; and test -d "/usr/local/bin"
    if not contains "/usr/local/bin" $PATH
        set -gx PATH /usr/local/bin $PATH
    end
end
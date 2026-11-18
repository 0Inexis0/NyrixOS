# Session-local colours; leave non-interactive fish and universal settings alone.
if status is-interactive
    set -g fish_color_normal ededed
    set -g fish_color_command a7ede1
    set -g fish_color_param ededed
    set -g fish_color_quote e5ce9f
    set -g fish_color_error ef9fa9
    set -g fish_color_comment 888888
    set -g fish_color_autosuggestion 888888
    set -g fish_color_operator c4b5e8
    set -g fish_color_cwd a7ede1
end

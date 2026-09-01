function enable-history
    set -ge fish_private_mode
    # Update to ensure automatic disabling is applied
    __jkemming__update_automatic_private_mode
end

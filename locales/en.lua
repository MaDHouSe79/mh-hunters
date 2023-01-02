local Translations = {
    info = {
        ['hunters_called'] = "Someone saw you and sent the hunters after you!",
        ['hunters_alive'] = "~r~%{count}~s~ hunters are still looking for you.",
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
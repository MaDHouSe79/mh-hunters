local Translations = {
    info = {
        ['hunters_called'] = "Iemand heeft je gezien en heeft de hunters gebeld!",
        ['hunters_alive'] = "~r~%{count}~s~ hunters zoeken je nog.",
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

local Translations = {
    info = {
        ['hunters_called'] = "Iemand heeft je gezien en heeft de hunters op je af gestuurd!",
        ['hunters_alive'] = "~r~%{count}~s~ hunters zoeken je nog.",
        ['hunter_alive'] = "~r~%{count}~s~ hunter zoekt je nog.",
        ['can_not_call_hunters'] = "Kan de hunters niet bellen, bel de politie!",
        ["you_lose_the_hunters"] = "De hunters zijn je uit het oog verloren!",
        ["you_lose_the_hunters"] = "Een hunter is je uit het oog verloren!",
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

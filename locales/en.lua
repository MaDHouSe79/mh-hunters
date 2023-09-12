local Translations = {
    info = {
        ['hunters_called'] = "Someone saw you and sent the hunters after you!",
        ['hunters_alive'] = "~r~%{count}~s~ hunters are still looking for you.",
        ['hunter_alive'] = "~r~%{count}~s~ hunter is still looking for you.",
        ['can_not_call_hunters'] = "Can't call the hunters, call the police!",
        ["you_lose_the_hunters"] = "The hunters have lost track of you!",
        ["you_lose_a_hunter"] = "A hunter have lost track of you!",
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

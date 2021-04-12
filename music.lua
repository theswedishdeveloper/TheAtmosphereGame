MUSIC_TRACK = nil
local isMusicPlaying = false

function SETUP_MUSIC_TRACK()
    
    MUSIC_TRACK = love.audio.newSource("assets/music.mp3", "static")
    MUSIC_TRACK:setVolume(MUSIC_VOLUME)
    MUSIC_TRACK:setLooping(true)

end

function PLAY_MUSIC_TRACK()

    if (not isMusicPlaying and MUSIC_TRACK) then
        MUSIC_TRACK:play()
        isMusicPlaying = true
    end

end

function PAUSE_MUSIC_TRACK()

    if (isMusicPlaying and MUSIC_TRACK) then
        MUSIC_TRACK:pause()
        isMusicPlaying = false
    end

end

function STOP_MUSIC_TRACK()

    if (isMusicPlaying and MUSIC_TRACK) then
        MUSIC_TRACK:stop()
        isMusicPlaying = false
    end

end
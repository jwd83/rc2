-- Simple procedural background music for the game
-- Creates a basic ambient loop using Love2D's audio capabilities

local music = {}

local musicSource = nil
local isPlaying = false

function music.init()
    -- Create a simple sine wave-based ambient track
    local sampleRate = 22050
    local duration = 8 -- 8 second loop
    local samples = sampleRate * duration
    
    -- Create sound data
    local soundData = love.sound.newSoundData(samples, sampleRate, 16, 1)
    
    -- Generate a simple ambient melody
    for i = 0, samples - 1 do
        local t = i / sampleRate
        local loopTime = t % duration
        
        -- Base frequency modulation
        local baseFreq = 220 -- A3
        local modulation = math.sin(loopTime * 0.5) * 0.1 + 1
        
        -- Create layered tones
        local wave1 = math.sin(2 * math.pi * baseFreq * modulation * t) * 0.15
        local wave2 = math.sin(2 * math.pi * baseFreq * modulation * 1.5 * t) * 0.1
        local wave3 = math.sin(2 * math.pi * baseFreq * modulation * 0.75 * t) * 0.08
        
        -- Add some texture with filtered noise
        local noise = (love.math.random() - 0.5) * 0.02
        local filteredNoise = noise * math.exp(-loopTime * 0.5)
        
        -- Envelope for smooth looping
        local envelope = 1
        if loopTime < 0.5 then
            envelope = loopTime * 2 -- Fade in
        elseif loopTime > duration - 0.5 then
            envelope = (duration - loopTime) * 2 -- Fade out
        end
        
        -- Combine waves
        local sample = (wave1 + wave2 + wave3 + filteredNoise) * envelope * 0.3
        
        -- Clamp to prevent distortion
        sample = math.max(-1, math.min(1, sample))
        
        soundData:setSample(i, sample)
    end
    
    -- Create audio source from generated data
    musicSource = love.audio.newSource(soundData, "static")
    musicSource:setLooping(true)
    musicSource:setVolume(0.3) -- Keep it subtle
end

function music.play()
    if musicSource and not isPlaying then
        love.audio.play(musicSource)
        isPlaying = true
    end
end

function music.stop()
    if musicSource and isPlaying then
        love.audio.stop(musicSource)
        isPlaying = false
    end
end

function music.setVolume(volume)
    if musicSource then
        musicSource:setVolume(volume)
    end
end

function music.isPlaying()
    return isPlaying and musicSource and musicSource:isPlaying()
end

return music
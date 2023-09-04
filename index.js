// debug = true;

// log('loading...');

// function log(log_message) {
//     if (debug) {
//         console.log(log_message);
//     }
// }

// let app;

// window.onload = function () {
//     log('window loaded');

//     app = new PIXI.Application({ width: 1280, height: 720, backgroundColor: 0x1099bb, resolution: window.devicePixelRatio || 1, });
//     document.body.appendChild(app.view);

//     let sprite = PIXI.Sprite.from('ship.png');
//     app.stage.addChild(sprite);


//     // Add a variable to count up the seconds our demo has been running
//     let elapsed = 0.0;
//     // Tell our application's ticker to run a new callback every frame, passing
//     // in the amount of time that has passed since the last tick
//     app.ticker.add((delta) => {
//         // Add the time to our total elapsed time
//         elapsed += delta;
//         // Update the sprite's X position based on the cosine of our elapsed time.  We divide
//         // by 50 to slow the animation down a bit...
//         sprite.x = 100.0 + Math.cos(elapsed / 50.0) * 100.0;
//     });



// }


window.onload = function () {
    const app = new PIXI.Application({ resizeTo: window });

    document.body.appendChild(app.view);

    const style = new PIXI.TextStyle({
        fontFamily: 'Arial',
        fontSize: 55,
        fontStyle: 'italic',
        fontWeight: 'bold',
        fill: ['#ffffff', '#00ff99'], // gradient
        stroke: '#4a1850',
        strokeThickness: 5,
        dropShadow: true,
        dropShadowColor: '#000000',
        dropShadowBlur: 4,
        dropShadowAngle: Math.PI / 6,
        dropShadowDistance: 6,
        // wordWrap: true,
        // wordWrapWidth: 440,
        lineJoin: 'round',
    });
    const style2 = new PIXI.TextStyle({
        fontFamily: 'Arial',
        fontSize: 90,
        fontStyle: 'italic',
        fontWeight: 'bold',
        fill: ['#ffffff', '#00ff99'], // gradient
        stroke: '#4a1850',
        strokeThickness: 7,
        dropShadow: true,
        dropShadowColor: '#000000',
        dropShadowBlur: 4,
        dropShadowAngle: Math.PI / 6,
        dropShadowDistance: 6,
        // wordWrap: true,
        // wordWrapWidth: 440,
        lineJoin: 'round',
    });
    const style3 = new PIXI.TextStyle({
        fontFamily: 'Arial',
        fontSize: 25,
        fontStyle: 'italic',
        fontWeight: 'bold',
        fill: ['#ffffff', '#00ff99'], // gradient
        stroke: '#4a1850',
        strokeThickness: 7,
        dropShadow: true,
        dropShadowColor: '#000000',
        dropShadowBlur: 4,
        dropShadowAngle: Math.PI / 6,
        dropShadowDistance: 6,
        // wordWrap: true,
        // wordWrapWidth: 440,
        lineJoin: 'round',
    });

    const richText = new PIXI.Text('T h e    H u n t    F o r', style);
    const richText2 = new PIXI.Text('Roy Carnassus', style2);
    const richText3 = new PIXI.Text('P a r t :    I I', style);
    const richText4 = new PIXI.Text('©️ 2005 Jack Games', style3);

    richText.anchor.set(0.5);
    richText2.anchor.set(0.5);
    richText3.anchor.set(0.5);
    richText4.anchor.set(0.5);


    app.stage.addChild(richText);
    app.stage.addChild(richText2);
    app.stage.addChild(richText3);
    app.stage.addChild(richText4);





    // Get the texture for star.
    const starTexture = PIXI.Texture.from('https://pixijs.com/assets/star.png');

    const starAmount = 2000;
    let cameraZ = 0;
    const fov = 20;
    const baseSpeed = 0.025;
    let speed = 0;
    let warpSpeed = 0;
    const starStretch = 5;
    const starBaseSize = 0.05;

    // Create the stars
    const stars = [];

    for (let i = 0; i < starAmount; i++) {
        const star = {
            sprite: new PIXI.Sprite(starTexture),
            z: 0,
            x: 0,
            y: 0,
        };

        star.sprite.anchor.x = 0.5;
        star.sprite.anchor.y = 0.7;
        randomizeStar(star, true);
        app.stage.addChild(star.sprite);
        stars.push(star);
    }

    function randomizeStar(star, initial) {
        star.z = initial ? Math.random() * 2000 : cameraZ + Math.random() * 1000 + 2000;

        // Calculate star positions with radial random coordinate so no star hits the camera.
        const deg = Math.random() * Math.PI * 2;
        const distance = Math.random() * 50 + 1;

        star.x = Math.cos(deg) * distance;
        star.y = Math.sin(deg) * distance;
    }

    // Change flight speed every 5 seconds
    setInterval(() => {
        warpSpeed = warpSpeed > 0 ? 0 : 1;
    }, 5000);

    // Listen for animate update
    app.ticker.add((delta) => {
        // Simple easing. This should be changed to proper easing function when used for real.
        speed += (warpSpeed - speed) / 20;
        cameraZ += delta * 10 * (speed + baseSpeed);
        for (let i = 0; i < starAmount; i++) {
            const star = stars[i];

            if (star.z < cameraZ) randomizeStar(star);

            // Map star 3d position to 2d with really simple projection
            const z = star.z - cameraZ;

            star.sprite.x = star.x * (fov / z) * app.renderer.screen.width + app.renderer.screen.width / 2;
            star.sprite.y = star.y * (fov / z) * app.renderer.screen.width + app.renderer.screen.height / 2;

            // Calculate star scale & rotation.
            const dxCenter = star.sprite.x - app.renderer.screen.width / 2;
            const dyCenter = star.sprite.y - app.renderer.screen.height / 2;
            const distanceCenter = Math.sqrt(dxCenter * dxCenter + dyCenter * dyCenter);
            const distanceScale = Math.max(0, (2000 - z) / 2000);

            star.sprite.scale.x = distanceScale * starBaseSize;
            // Star is looking towards center so that y axis is towards center.
            // Scale the star depending on how fast we are moving, what the stretchfactor is
            // and depending on how far away it is from the center.
            star.sprite.scale.y = distanceScale * starBaseSize
                + distanceScale * speed * starStretch * distanceCenter / app.renderer.screen.width;
            star.sprite.rotation = Math.atan2(dyCenter, dxCenter) + Math.PI / 2;
        }


        richText.x = app.renderer.width / 2;
        richText.y = app.renderer.height / 10 * 1;

        richText2.x = app.renderer.width / 2;
        richText2.y = app.renderer.height / 10 * 2;

        richText3.x = app.renderer.width / 2;
        richText3.y = app.renderer.height / 10 * 3;

        richText4.x = app.renderer.width / 2;
        richText4.y = app.renderer.height / 10 * 9;
    });

}

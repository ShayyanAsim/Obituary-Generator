import React from 'react';
import {useState} from 'react';

function Obituary({obit, currentAudio, onPlay, onStop, created}){
    const [audio, setAudio] = useState(obit ? new Audio(obit.audio) : null);
    
    const toggle = () => {
        const btn = document.getElementById("btn-" + obit.id);
        if (btn.innerHTML === "▶") {
            onPlay(audio);
            btn.innerHTML = "&#x23F8;";
            audio.addEventListener("ended", () => {
                btn.innerHTML = "&#9654;";
                onStop();                
            });
            audio.addEventListener("pause", () => {
                btn.innerHTML = "&#9654;";
            });
        } else {
            btn.innerHTML = "&#9654;";
            onStop();
        }
    };

    const hideText = () => {
        console.log("hide text");
        const text = document.getElementById("text-" + obit.id);
        const btn = document.getElementById("btn-" + obit.id);
        if(text.style.display === "none"){
            text.style.display = "block";
            btn.style.display = "inline";
            
        } else{
            text.style.display = "none";
            btn.style.display = "none";
        }
    };

    const convertDateFormat = (date) => {
        var newDate = new Date(date);
        const dateString2 = newDate.toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' });
        return dateString2;
    }
    return ( obit ?
        <div className="obit-container" onLoad={created}>
            <img onClick={hideText} src={obit.img.replace("/upload/", "/upload/e_art:zorro/")}/>
            <h2 className="name">{obit.name}</h2>
            <h3 className="date">{convertDateFormat(obit.born)} - {convertDateFormat(obit.died)}</h3>
            <p id={"text-" + obit.id}>{obit.text}</p>
            <button id={"btn-" + obit.id} onClick={toggle} className="play-pause-btn">&#9654;</button>
        </div>
        : <div>Empty</div>
    );
}

export default Obituary;
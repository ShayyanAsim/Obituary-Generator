import Obituary from "./Obituary";
import AddObit from "./AddObit";
import { useEffect, useState } from "react";
import { v4 as uuidv4 } from "uuid";

function App() {


  const [isOpen, setIsOpen] = useState(false);
  const [obits, setObits] = useState([]);
  const [currentAudio, setCurrentAudio] = useState(null);


  const loadOBits = async () => {
    const res = await fetch(`https://pwadkyn2fzel2dyntk7ejiobxy0rltop.lambda-url.ca-central-1.on.aws/`);
    const data = await res.json();
  

    for(var i = 0; i < data.data.length; i++){
      addObit(data.data[i].name, data.data[i].picture_url, data.data[i].year_born, data.data[i].year_died, data.data[i].obituary, data.data[i].audio_url,data.data[i].id);
    }
  }

  useEffect(() => {
    loadOBits();
  }, []);


  const created = () => {
    if(obits.length < 1) return;
    for(let i = 0; i < obits.length; i++){
      if(i === 0){
        let id = obits[i].id;
        let text = document.getElementById("text-" + id);
        let btn = document.getElementById("btn-" + id);
        text.style.display = "block";
        btn.style.display = "inline";
      } else{
        let id = obits[i].id;
        let text = document.getElementById("text-" + id);
        let btn = document.getElementById("btn-" + id);
        text.style.display = "none";
        btn.style.display = "none";
      }
    }
  }


  const addObit = (name, img, born, died, text, audio, id) => {
    const newObit = {
        id: id,
        name: name, 
        born: born, 
        died: died,
        img: img,
        audio: audio,
        text: text
      };


      setObits(prev => {
        const obitIds = new Set(prev.map(obit => obit.id));
        return obitIds.has(id) ? prev : [newObit, ...prev];
      });
  };

  const openPop = () => {
    setIsOpen(true);
  }

  const closePop =() => {
    loadOBits();
    setIsOpen(false);
  }

  const playAudio = (audio) => {
    if (currentAudio) {
      currentAudio.pause();
      currentAudio.currentTime = 0;
    }
    setCurrentAudio(audio);
    audio.play();
  };

  const stopAudio = () => {
    if (currentAudio) {
      currentAudio.pause();
      currentAudio.currentTime = 0;
      setCurrentAudio(null);
    }
  };

  return (
    <div id="container">
      {!isOpen ? (<></>) : (<AddObit closePop={closePop}/>)}
      <header>
        <button id="invis-button">+ New Obituary</button>
        <h1>The Last Show</h1>
        <button onClick={openPop}>+ New Obituary</button>
      </header>
      <section id="obits">
        {obits.length > 0 ? (
          obits.map((obit) => <Obituary key={obit.id} obit={obit} currentAudio={currentAudio} onPlay={playAudio} onStop={stopAudio} created={created}/>)
        ) : (
          <h6 id="none">No Obituaries Yet</h6>
        )}
      </section>
    </div>
  );
}

export default App;
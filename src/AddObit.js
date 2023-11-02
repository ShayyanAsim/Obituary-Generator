import { useState } from "react";
import { v4 as uuidv4 } from 'uuid';

function AddObit({ closePop }){
    // Timezone
    var dateString = new Date().toLocaleString('en-CA', { timeZone: 'America/Edmonton', hour12:false });
    if (dateString.slice(12,14) === "24"){
        var hour = "00";
    } else{var hour = dateString.slice(12,14);}
    var time = dateString.slice(0,10) + "T" + hour + dateString.slice(14,20);
    console.log("Current time is: " + time);
    // Just discovered you can put emojis in code 😂
    const [name, setName] = useState("");
    const [yearBorn, setYearBorn] = useState("");
    const [yearPassed, setYearPassed] = useState(time.slice(0,16));
    const [file, setFile] = useState(null);
    const [isFilled, setIsFilled] = useState(true);
   
    
    const close = () => {
        closePop();
    };


    const submitObit = async () => {

        document.getElementById("submit-btn").disabled = true;
        const data = new FormData();
        data.append("file",file);

        if(file === null || name === "" || yearBorn === "" || yearPassed === ""){
            setIsFilled(false);
        } else{
            setIsFilled(true);
            document.getElementById("submit-btn").innerHTML = "Generating... Please wait";
            const url = `https://ydirb63ev2iykkooja6fwbagmm0lnylf.lambda-url.ca-central-1.on.aws`+
            `?name=${name}&year_born=${yearBorn}&year_died=${yearPassed}`;
            const res = await fetch(url, {
                method: "POST",
                headers:{
                    "Authentification": "",
                    "id": uuidv4()
                  },
                body: data,
                }
            );
            try{
                const response_content = await res.json();
                const values = JSON.parse(response_content);
            }   catch{
            }
            
            close();
            document.getElementById("submit-btn").disabled = false;
        }
    };



    const onFileChange = (e) =>{
        setFile(e.target.files[0]);
        document.getElementById("filename").innerHTML = "(" + e.target.files[0].name + ")";
    };

    return(
        <div id="pop-container">
            <button onClick={close} id="esc-btn">X</button>
            <h1>Create a New Obituary</h1>
            <img id="flower-img" src="http://clipart-library.com/images_k/black-and-white-flowers-transparent/black-and-white-flowers-transparent-11.png"></img>
            <form>
                <label>
                    Select an image for the deceased 
                    <input id="file-in" type="file" required accept="images/*" onChange={(e) => onFileChange(e)}/>
                    <span id="filename"></span>
                </label>
                <br/>
                <input id="name-in" type="text" placeholder="Name of the deceased" value={name} onChange={(e) => setName(e.target.value)}/>
                <div id="dates-in">
                    <p>Born:  <input type="datetime-local" value={yearBorn} onChange={(e)=>setYearBorn(e.target.value)}required/></p>
                    <p>Died:  <input type="datetime-local" value={yearPassed} onChange={(e)=>setYearPassed(e.target.value)} required/></p>
                </div>
                {isFilled ? (<></>) : (<p id="error-msg">Please make sure that all fields are filled</p>)}
                <button id="submit-btn" type="button" onClick={submitObit}>Write Obituary</button>
            </form>
        </div>
    );
}

export default AddObit;
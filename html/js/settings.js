document.addEventListener("DOMContentLoaded", () => {

    document.getElementById('updateRate').addEventListener('change', (e) => {
    update_rate = parseInt(e.target.value);
    send_api(update_rate,"set_update_rate")
    })
    let save_field = 0;
    window.savebtn = (input_field) => {
    save_field = input_field;
    save();
    }
    window.reset =()=> {
        reset();
    }
    window.calibrate = () => {
        calibrate();
    }
    const API_BASE = (window.API_BASE || '/api').replace(/\/+$/,'');
    async function reset() {
    let res = await fetch(`${API_BASE}/reset`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
            });
            if (!res) throw new Error("Fehler")    
    }
    async function calibrate() {
    let res = await fetch(`${API_BASE}/calibrate`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                          });
            if (!res) throw new Error("Fehler")
            }
    async function save(){
        let input_value
        if(save_field == "delay_ch1") {
            value = document.getElementById("input_delay_ch1").value;
            await send_api(value,"set_delay/1")
        }else if (save_field == "delay_ch2"){
            value = document.getElementById("input_delay_ch2").value;
            await send_api(value,"set_delay/2");
        }else if (save_field == "dead_time"){
            value = document.getElementById("input_dead_time").value;
            await send_api(value,"input_dead_time");
        }else if (save_field == "time_window"){
            value = document.getElementById("input_time_window").value;
            await send_api(value,"set_time_window");
        }
}
    async function change_update_rate() {
        let value = this.updateRate;
        let res = await fetch(`${API_BASE}/set_update_rate`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
           body: JSON.stringify({ value })
        });
        if (!res) throw new Error("Fehler");
            }
    async function send_api(value,path){
        let res = await fetch(`${API_BASE}/${path}`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
           body: JSON.stringify({ value })
        });
        if (!res) throw new Error("Fehler");
            }

 // ----- Zeiten (CH1/CH2) jede Sekunde abrufen -----
    async function fetchTimes(){
      try{
        // Erwartetes Format vom Server: { ch1: <int>, ch2: <int> }
        const r = await fetch(`${API_BASE}/read_time`, { cache:'no-store' });
        if(!r.ok) throw new Error(`${r.status} ${r.statusText}`);
        const j = await r.json();
        document.getElementById('time_ch1').textContent = j.ch1 ?? '–';
        document.getElementById('time_ch2').textContent = j.ch2 ?? '–';
      }catch(_){}
    }
    fetchTimes();
    setInterval(fetchTimes, 1000);
});

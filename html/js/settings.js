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
            fetchTimes();
        }else if (save_field == "delay_ch2"){
            value = document.getElementById("input_delay_ch2").value;
            await send_api(value,"set_delay/2");
            fetchTimes();
        }else if (save_field == "delay_ch3") {
            value = document.getElementById("input_delay_ch3").value;
            await send_api(value, "set_delay/3");
            fetchTimes();
        }else if (save_field == "delay_ch4"){
            value = document.getElementById("input_delay_ch4").value;
            await send_api(value,"set_delay/4");
            fetchTimes();
        }else if (save_field == "delay_ch5"){
            value = document.getElementById("input_delay_ch5").value;
            await send_api(value,"set_delay/5");
            fetchTimes();
        }else if(save_field == "delay_ch6"){
            value = document.getElementById("input_delay_ch6").value;
            await send_api(value, "set_delay/6");
            fetchTimes();
        }else if (save_field == "delay_ch7"){
            value = document.getElementById("input_delay_ch7").value;
            await send_api(value,"set_delay/7")
            fetchTimes();
        }else if (save_field == "delay_ch8"){
            value = document.getElementById("input_delay_ch8").value;
            await  send_api(value,"set_delay/8");
            fetchTimes();
        }
            else if (save_field == "dead_time"){

            value = document.getElementById("input_dead_time").value;
            await send_api(value,"input_dead_time");
            fetchTimes()
        }else if (save_field == "time_window"){
            value = document.getElementById("input_time_window").value;
            await send_api(value,"set_time_window");
            fetchTimes()
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
        const times = await r.json();
        document.getElementById('time_ch1').textContent = times.ch1 ?? '–';
        document.getElementById('time_ch2').textContent = times.ch2 ?? '–';
        document.getElementById('time_ch3').textContent = times.ch3 ?? '-';
        document.getElementById('time_ch4').textContent = times.ch4 ?? '-';
        document.getElementById('time_ch5').textContent = times.ch5 ?? '-';
        document.getElementById('time_ch6').textContent = times.ch6 ?? '-';
        document.getElementById('time_ch7').textContent = times.ch7 ?? '-';
        document.getElementById('time_ch8').textContent = times.ch8 ?? '-';

        document.getElementById("diff1_5").textContent = times.ch1 - times.ch5 ?? '-';
        document.getElementById("diff1_6").textContent = times.ch1 - times.ch6 ?? '-';
        document.getElementById("diff1_7").textContent = times.ch1 - times.ch7 ?? '-';
        document.getElementById("diff1_8").textContent = times.ch1 - times.ch8 ?? '-';

        document.getElementById("diff2_5").textContent = times.ch2 - times.ch5 ?? '-';
        document.getElementById("diff2_6").textContent = times.ch2 - times.ch6 ?? '-';
        document.getElementById("diff2_7").textContent = times.ch2 - times.ch7 ?? '-';
        document.getElementById('diff2_8').textContent = times.ch2 - times.ch8 ?? '-';

        document.getElementById('diff3_5').textContent = times.ch3 - times.ch5 ?? '-';
        document.getElementById('diff3_6').textContent = times.ch3 - times.ch6 ?? '-';
        document.getElementById('diff3_7').textContent = times.ch3 - times.ch7 ?? '-';
        document.getElementById('diff3_8').textContent = times.ch3 - times.ch8 ?? '-';

        document.getElementById("diff4_5").textContent = times.ch4 - times.ch5 ?? '-';
        document.getElementById("diff4_6").textContent = times.ch4 - times.ch6 ?? '-';
        document.getElementById("diff4_7").textContent = times.ch4 - times.ch7 ?? '-';
        document.getElementById("diff4_8").textContent = times.ch4 - times.ch8 ?? '-';

        document.getElementById("diff5_1").textContent = times.ch5 - times.ch1 ?? '-';
        document.getElementById("diff5_2").textContent = times.ch5 - times.ch2 ?? '-';
        document.getElementById("diff5_3").textContent = times.ch5 - times.ch3 ?? '-';
        document.getElementById('diff5_4').textContent = times.ch5 - times.ch4 ?? '-';

        document.getElementById('diff6_1').textContent = times.ch6 - times.ch1 ?? '-';
        document.getElementById('diff6_2').textContent = times.ch6 - times.ch2 ?? '-';
        document.getElementById('diff6_3').textContent = times.ch6 - times.ch3 ?? '-';
        document.getElementById('diff6_4').textContent = times.ch6 - times.ch4 ?? '-';

        document.getElementById("diff7_1").textContent = times.ch7 - times.ch1 ?? '-';
        document.getElementById("diff7_2").textContent = times.ch7 - times.ch2 ?? '-';
        document.getElementById("diff7_3").textContent = times.ch7 - times.ch3 ?? '-';
        document.getElementById('diff7_4').textContent = times.ch7 - times.ch4 ?? '-';

        document.getElementById('diff8_1').textContent = times.ch8 - times.ch1 ?? '-';
        document.getElementById('diff8_2').textContent = times.ch8 - times.ch2 ?? '-';
        document.getElementById('diff8_3').textContent = times.ch8 - times.ch3 ?? '-';
        document.getElementById('diff8_4').textContent = times.ch8 - times.ch4 ?? '-';


      }catch(_){}
    }
    fetchTimes();
    setInterval(fetchTimes, 1000);
});

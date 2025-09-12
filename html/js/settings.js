document.addEventListener("DOMContentLoaded", () => {
    let save_field = 0;
    window.savebtn = (input_field) => {
    save_field = input_field;
    save();
    }
    const API_BASE = (window.API_BASE || '/api').replace(/\/+$/,'');
    async function save(){
        let input_value
        if(save_field == "delay_ch1") {
            input_value = document.getElementById("input_delay_ch1").value;
            let res = await fetch(`${API_BASE}/set_delay/1`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ input_value })
            });
            if (!res) throw new Error("Fehler");
        }else if (save_field == "delay_ch2"){
            input_value = document.getElementById("input_delay_ch2").value;
            const res = await fetch(`${API_BASE}/set_delay/2`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ input_value })
             });
             if (!res) throw new Error("Fehler");
        }else if (save_field == "dead_time"){
            input_value = document.getElementById("input_dead_time").value;
            let res = await fetch(`${API_BASE}/set_dead_time`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ input_value })
            });
            if (!res) throw new Error("Fehler");
        }else if (save_field == "time_window"){
            input_value = document.getElementById("input_time_window").value;
            let res = await fetch(`${API_BASE}/set_time_window/1`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ input_value })
            });
            if (!res) throw new Error("Fehler");
        }

}
});
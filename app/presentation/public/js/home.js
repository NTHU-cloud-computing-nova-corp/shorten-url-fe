function copy_short_url() {
    const short_url = document.getElementById('short_url').value;
    navigator.clipboard.writeText(short_url);
}
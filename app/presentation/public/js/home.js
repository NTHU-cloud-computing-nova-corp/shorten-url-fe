function copy_short_url() {
    const short_url = document.getElementById('short_url_output').value;
    navigator.clipboard.writeText(short_url);
}
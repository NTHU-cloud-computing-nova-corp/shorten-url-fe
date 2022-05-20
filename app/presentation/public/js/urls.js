$(document).ready(function () {
    $('#url_list').DataTable({
        columnDefs: [{
            targets: 1,
            render: function (data, type, row) {
                if (type === 'display') {
                    return $.fn.dataTable.render.ellipsis(50)(data, type, row);
                }
                return data;
            }
        }]
    });

    document.querySelector("#url_list > tbody > tr > td:nth-child(2)")
});

copy_url = (short_url) => {
    navigator.clipboard.writeText(short_url);
}

open_delete_url_modal = (short_url) => {
    document.getElementById('delete-title').innerText = `Confirm delete : ${short_url}`
    document.getElementById('delete-short-url').value = short_url
    $('#delete-url-modal').modal('show')
}

open_update_url_modal = (url) => {
    document.getElementById("add-tag-area").textContent = ''
    document.getElementById("remove-tag-area").textContent = ''

    url = JSON.parse(url)
    document.getElementById('update-url-id').value = url.id
    document.getElementById('update-long-url').value = url.long_url
    document.getElementById('update-description').value = url.description
    document.getElementById('update-status-code').select = url.status_code
    document.getElementById('update-tags').value = url.tags

    url.tags.split(",").forEach(tag => {
        add_new_tag(tag)
    })

    $('#update-url-modal').modal('show')
}

set_update_tag = () => {
    const tags_element = Array.from(document.querySelectorAll("#add-tag-area > a > span"))
    const tags = tags_element.map(m => m.innerHTML).join(",")
    document.getElementById("update-tags").value = tags
}

remove_tag = (element_id) => {
    const value = document.getElementById("tag-" + element_id).innerText
    document.getElementById("a-" + element_id).remove()

    const remove_element_id = document.querySelectorAll("#remove-tag-area > a").length + 1
    let a = document.createElement("a")
    a.id = "rm-a-" + remove_element_id
    a.classList.add("btn")
    a.addEventListener("click", () => {
        add_new_tag(value)
        document.getElementById("rm-a-" + remove_element_id).remove()
    });
    let tag = document.createElement("span");
    tag.id = "rm-tag-" + element_id
    tag.classList.add("badge", "rounded-pill", "bg-danger")
    tag.innerHTML = value

    a.append(tag)
    document.getElementById("remove-tag-area").append(a)
    set_update_tag()
}

add_new_tag = (value) => {
    if (!value) value = document.getElementById("new-tag-input").value

    const element_id = document.querySelectorAll("#add-tag-area > a").length + 1
    let a = document.createElement("a")
    a.id = "a-" + element_id
    a.classList.add("btn")
    a.addEventListener("click", () => remove_tag(element_id));
    let tag = document.createElement("span");
    tag.id = "tag-" + element_id
    tag.classList.add("badge", "rounded-pill", "bg-primary")
    tag.innerHTML = value

    a.append(tag)
    document.getElementById("add-tag-area").append(a)
    set_update_tag()
}
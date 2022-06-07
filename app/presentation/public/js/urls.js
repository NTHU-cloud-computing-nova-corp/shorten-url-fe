$(document).ready(function () {
    $('#url_list').DataTable({
        stripeClasses: [],
        ordering: false,
        columnDefs: [{
            targets: 2, render: function (data, type, row) {
                if (type === 'display') {
                    return $.fn.dataTable.render.ellipsis(50)(data, type, row);
                }
                return data;
            }
        }]
    });

    document.querySelector("#url_list > tbody > tr > td:nth-child(2)")
});

open_send_invite_modal = (url) => {
    $('#send-invitation-modal').modal('show')

    document.getElementById("invite-email-container").textContent = ''

    url = JSON.parse(url)
    document.getElementById('invite-short-url').value = url.short_url
    document.getElementById('invite-emails').value = url.shared_email_list

    url.shared_email_list.split(",").forEach(email => {
        let mainDiv = document.createElement("div")
        // mainDiv.id = container_id + "-div-input-" + order
        mainDiv.classList.add("col-12", "form-group", "my-2")
        mainDiv.style.width = "auto"
        mainDiv.style.alignSelf = "center"

        let span = document.createElement("span")
        span.classList.add("badge", "rounded-pill", "bg-light")
        span.innerText = email

        mainDiv.appendChild(span)
        document.getElementById("invite-email-container").appendChild(mainDiv)

    })
}

copy_url = (short_url) => {
    navigator.clipboard.writeText(short_url);
}

lock_url = (short_url) => {
    $('#lock-url-modal').modal('show')
    document.getElementById('lock-short-url').value = short_url
}

share_url = (short_url, shared_email_list) => {
    document.getElementById("new-shared-email-container").textContent = ''

    $('#share-email-modal').modal('show')
    document.getElementById('share-short-url').value = short_url
    share_btn = document.getElementById('share-url-btn')

    if (shared_email_list != "") {
        shared_email_list.split(",").forEach(email => {
            append_new_input("new-shared-email", email)
        })
        share_btn.disable = false
    } else {
        share_btn.disable = true
        add_new_input('new-shared-email', 'email')
    }
}

open_url = (short_url) => {
    $('#open-url-modal').modal('show')
    document.getElementById('open-short-url').value = short_url
}

privatise_url = (short_url) => {
    $('#privatise-url-modal').modal('show')
    document.getElementById('privatise-short-url').value = short_url
}

open_delete_url_modal = (short_url) => {
    document.getElementById('delete-title').innerText = `Confirm delete : ${short_url}`
    document.getElementById('delete-short-url').value = short_url
    $('#delete-url-modal').modal('show')
}

open_update_url_modal = (url) => {
    document.getElementById("new-tag-container").textContent = ''

    url = JSON.parse(url)
    document.getElementById('update-url-id').value = url.id
    document.getElementById('update-short-url').value = url.short_url
    document.getElementById('update-long-url').value = url.long_url
    document.getElementById('update-description').value = url.description
    document.getElementById('new-tag-update-input').value = url.tags

    if (url.tags != "") {
        url.tags.split(",").forEach(tag => {
            append_new_input("new-tag", tag)
        })
    } else {
        add_new_input('new-tag', 'tag')
    }

    $('#update-url-modal').modal('show')
}

set_update_input = (container_id) => {
    const input_element = Array.from(document.querySelectorAll(`#${container_id}-container > div > span`))
    const inputs = input_element.map(m => m.textContent).join(",")
    document.getElementById(`${container_id}-update-input`).value = inputs

    console.log("container_id, inputs", container_id, inputs)
    let share_btn;
    if (container_id === 'new-shared-email') {
        share_btn = document.getElementById('share-url-btn')
        if (!inputs) {
            share_btn.disabled = true
        } else {
            share_btn.disabled = false
        }
    }


}

function mouseEnter(event) {
    // highlight the mouseenter target
    event.target.style.color = "red";

    // reset the color after a short delay
    setTimeout(function () {
        event.target.style.color = "lightgray";
    }, 500);
}

remove_input = (container_id, id) => {
    let ele = document.getElementById(id)
    if (ele) ele.remove()

    set_update_input(container_id)
}

append_new_input = (container_id, value) => {
    const order = document.querySelectorAll(`${container_id}-container > div > span`).length + 1

    let mainDiv = document.createElement("div")
    mainDiv.id = container_id + "-div-input-" + order
    mainDiv.classList.add("col-12", "form-group", "my-2")
    mainDiv.style.width = "auto"
    mainDiv.style.alignSelf = "center"

    let span = document.createElement("span")
    span.id = container_id + "-span-input-" + order
    span.classList.add("badge", "rounded-pill", "bg-light")
    span.innerText = value

    let i = document.createElement("i")
    i.id = container_id + "-i-input-" + order
    i.style.cursor = "pointer"
    i.style.color = "lightgray"
    i.style.marginLeft = "5px"
    i.classList.add("fa-solid", "fa-circle-xmark")
    i.addEventListener("mouseenter", mouseEnter, false);
    i.addEventListener("click", function () {
        remove_input(container_id, mainDiv.id)
    }, false);

    span.appendChild(i)
    mainDiv.appendChild(span)
    document.getElementById(`${container_id}-container`).appendChild(mainDiv)
    remove_input(container_id, `${container_id}-div`)
    set_update_input(container_id)
}

add_new_input = (container_id, type) => {
    if (document.getElementById(`${container_id}-div`) != null) {
        document.getElementById(`${container_id}-div`).focus()
        return;
    }
    let mainDiv = document.createElement("div")
    mainDiv.id = `${container_id}-div`
    mainDiv.classList.add("col-12")
    mainDiv.style.display = "flex"
    mainDiv.style.justifyContent = "flex-start"
    mainDiv.style.flexDirection = "row"
    mainDiv.style.alignItems = "center"

    let div = document.createElement("div")
    div.classList.add("form-group")
    div.style.width = type == 'email' ? "35%" : "20%"

    let input = document.createElement("input")
    input.id = `${container_id}-input`
    input.classList.add("form-control", "form-control-sm")
    input.style.height = "25px"
    input.placeholder = `Enter ${type}`
    input.style.borderRadius = "30px"
    input.type = type

    input.addEventListener("change", function () {
        append_new_input(container_id, document.getElementById(input.id).value)
    })

    let deleteTag = document.createElement("i")
    deleteTag.id = `${container_id}-rm-i`
    deleteTag.classList.add("fa-solid", "fa-circle-xmark")
    deleteTag.style.margin = "-25px"
    deleteTag.style.cursor = "pointer"
    deleteTag.style.color = "lightgray"
    deleteTag.addEventListener("mouseenter", mouseEnter, false);
    deleteTag.addEventListener("click", function () {
        remove_input(container_id, mainDiv.id)
    }, false);

    div.append(input)
    mainDiv.append(div)
    mainDiv.append(deleteTag)
    document.getElementById(`${container_id}-container`).appendChild(mainDiv)
}
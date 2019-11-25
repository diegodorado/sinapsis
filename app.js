const j = document.getElementById('j')
const f = document.getElementById('f')
const s = document.getElementById('s')
const b = document.getElementById('bg')
const h = document.getElementById('hm')


h.querySelector('button').addEventListener('click', (ev)=> {
  h.remove()
  document.getElementById('ctls').style = ''
})

if (!!navigator.platform && /iPad|iPhone|iPod/.test(navigator.platform)) {
  document.getElementsByTagName('html')[0].classList.add('ios')
}

let hex = (el) => ('0' + el.v.toString(16)).slice(-2)

let last_req = 0
let responded = false
let udpate = (t) => {
  if ((responded || t - last_req > 2000) && changed()) {
    responded = false
    let url = '/c/' + hex(j) + hex(f) + hex(s)
    let req = new XMLHttpRequest()
    req.onreadystatechange = () => {
      if (req.readyState == 4 && req.status == 200)
        responded = true
    }
    req.open("GET", url, true)
    req.send(null)
    last_req = t
  }
  window.requestAnimationFrame(udpate)
}

let changed = () => {
  if (j.v == Math.floor(j.value) && f.v == Math.floor(f.value) && s.v == Math.floor(s.value))
    return false

  j.v = Math.floor(j.value)
  f.v = Math.floor(f.value)
  s.v = Math.floor(s.value)

  b.style.setProperty('--hw', 20 + j.v / 255 * 160);
  b.style.setProperty('--hc', 180 + f.v / 255 * 180);
  b.style.setProperty('--sat', ((j.v + f.v) < 63) ? (50 + (j.v + f.v) / 63 * 50) + '%' : '100%');
  b.style.setProperty('--ll', ((j.v + f.v) < 63) ? (100 - (j.v + f.v) / 63 * 50) + '%' : '50%');
  b.style.setProperty('--ss', (s.v / 255));
  b.style.setProperty('--sst', (10 - 9 * s.v / 255) + 's');
  return true
}

window.requestAnimationFrame(udpate);

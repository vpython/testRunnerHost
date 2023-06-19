<script lang="ts">
	import { env } from '$env/dynamic/public'

	type RSEvent = {
		type: string
		key: string
	}
	import { onMount } from 'svelte'
	let code = 'Web VPython 3.2\n\nsphere()'
	let iframe: HTMLIFrameElement
	let ready = false
	let trusted_guest = new URL(env.PUBLIC_RUNNER_GUEST_URL).origin

	function sendMessage(msg: string) {
		if (ready && iframe.contentWindow) {
			console.log('Sending message: to guest' + msg)
			iframe.contentWindow.postMessage(msg, trusted_guest)
		}
	}

	function sendEvent(ev: Event) {
		// Forward some key events to the iframe, since otherwise it might not get them depending on focus
		// TODO: This is far from perfect.  The iframe receives many events twice, the right context menu is not blocked
		// when a right-spin drag begins inside the iframe but ends outside, not all event data is forwarded, etc.
		let sendEvent: RSEvent
		if (ev.type == 'keydown' || ev.type == 'keyup') {
			sendEvent = { type: ev.type, key: (ev as KeyboardEvent).key }
		} else return
		if (ready) {
			sendMessage(JSON.stringify({ event: sendEvent }))
		}
	}

	onMount(() => {
		console.log('guest URL:' + env.PUBLIC_RUNNER_GUEST_URL)
		iframe.src = env.PUBLIC_RUNNER_GUEST_URL
		window.onmessage = (event) => {
			let data = JSON.parse(event.data)
			console.log('Got data from iframe:', JSON.stringify(data))
			if (data.ready) {
				ready = true
				sendMessage(
					JSON.stringify({
						program: code,
						version: '3.2',
						lang: 'vpython'
					})
				)
			}
		}

		document.onkeydown = (event) => sendEvent(event)
		document.onkeyup = (event) => sendEvent(event)
	})
</script>

<iframe bind:this={iframe} class="untrusted-frame" frameborder="20" title="runner" />

<style>
	iframe.untrusted-frame {
		border-style: none;
		border: 0;
		width: 100vw;
		height: 100vh;
		margin: 0;
		padding: 0;
		font-size: 80%;
	}
</style>

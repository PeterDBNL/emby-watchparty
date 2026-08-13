import { computed } from 'vue'
import { usePartyStore } from '@/stores/party'
import { useAuthStore } from '@/stores/auth'

export function useHostLock() {
    const party = usePartyStore()
    const auth = useAuthStore()

    const enabled = computed(() => party.hostLock.enabled)

    const canBrowseLibrary = computed(() => {
        if (!party.hostLock.enabled)
            return true

        if (auth.isHost)
            return true

        return party.hostLock.allowGuestBrowseLibrary
    })

    const canControlPlayback = computed(() => {
        if (!party.hostLock.enabled)
            return true

        if (auth.isHost)
            return true

        return party.hostLock.allowGuestMediaPlayback
    })

    const canChangeSubtitles = computed(() => {
        if (!party.hostLock.enabled)
            return true

        if (auth.isHost)
            return true

        return party.hostLock.allowGuestSubtitles
    })

    const canChangeAudio = computed(() => {
        if (!party.hostLock.enabled)
            return true

        if (auth.isHost)
            return true

        return party.hostLock.allowGuestAudio
    })

    const canChangeVideoQuality = computed(() => {
        if (!party.hostLock.enabled)
            return true

        if (auth.isHost)
            return true

        return party.hostLock.allowGuestVideoQuality
    })

    const canUseSocial = computed(() => {
        if (!party.hostLock.enabled)
            return true

        if (auth.isHost)
            return true

        return party.hostLock.allowGuestSocial
    })

    return {
        enabled,
        canBrowseLibrary,
        canControlPlayback,
        canChangeSubtitles,
        canChangeAudio,
        canChangeVideoQuality,
        canUseSocial,
    }
}
import { STATES, STATUS_ICONS } from '../../constants';

/**
 * Status als Label (A), Pill mit Icon (B) oder Farbpunkt mit Text (C).
 * Immer mit Wort – nie nur Farbe.
 */
export default {
    template: `
<span
    class="__P__-status"
    :class="'__P__-status--' + state"
>
    <mt-icon
        class="__P__-status__icon"
        :name="icon"
        size="11px"
    />
    <span>{{ label }}</span>
</span>`,

    props: {
        state: {
            type: String,
            required: true,
            validator: (value) => STATES.includes(value),
        },

        label: {
            type: String,
            required: true,
        },
    },

    computed: {
        icon() {
            return STATUS_ICONS[this.state];
        },
    },
};

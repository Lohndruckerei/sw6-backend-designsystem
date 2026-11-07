import { TRANSPORTS } from '../../constants';

/**
 * Übertragungsweg als Chip – Farbe, Icon und Bezeichnung sind in allen Plugins gleich.
 *
 * transport: email | ftp | sftp | portal_manual | rest_api | soap | webhook
 */
export default {
    template: `
<__P__-chip
    :label="label"
    :color="config.color"
    :icon="config.icon"
    :title="title"
/>`,

    props: {
        transport: {
            type: String,
            required: true,
        },

        title: {
            type: String,
            required: false,
            default: null,
        },
    },

    computed: {
        config() {
            return TRANSPORTS[this.transport] ?? { color: 'c4', icon: 'regular-plug' };
        },

        label() {
            const key = `__P__-design.transports.${this.transport}`;

            return this.$te(key) ? this.$tc(key) : this.transport;
        },
    },
};

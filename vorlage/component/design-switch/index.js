import { DESIGNS } from '../../constants';

/**
 * Schalter „Design A | B | C“ für den Praxistest. Speichert die Wahl je Benutzer.
 * Dahinter „Markieren“: Plugin-Markierung (Testmodus) für alle Lohndruckerei-Plugins, siehe marker.js.
 * Platz: Smart-Bar (#smart-bar-actions), vor „Speichern“.
 */
export default {
    template: `
<div class="__P__-design-switch" role="group" :aria-label="$tc('__P__-design.switchLabel')">
    <span class="__P__-design-switch__label">{{ $tc('__P__-design.switchLabel') }}</span>
    <button
        v-for="design in designs"
        :key="design.key"
        v-tooltip.bottom="{ message: design.title, appearance: 'light' }"
        type="button"
        class="__P__-design-switch__option"
        :class="{ 'is--active': design.key === current }"
        :aria-pressed="design.key === current ? 'true' : 'false'"
        @click="select(design.key)"
    >
        {{ design.key.toUpperCase() }}
    </button>
    <button
        v-tooltip.bottom="{ message: $tc('__P__-design.marker.toggleTitle'), appearance: 'light' }"
        type="button"
        class="__P__-design-switch__option __P__-design-switch__marker"
        :class="{ 'is--active': markerActive }"
        :aria-pressed="markerActive ? 'true' : 'false'"
        @click="toggleMarker"
    >
        {{ $tc('__P__-design.marker.toggle') }}
    </button>
</div>`,

    data() {
        return {
            markerActive: window.ldAdminMarker?.active ?? false,
            markerOff: null,
        };
    },

    computed: {
        store() {
            return Shopware.Store.get('__P__Design');
        },

        current() {
            return this.store.design;
        },

        designs() {
            return DESIGNS.map((key) => {
                const isDefault = key === this.store.defaultDesign;

                return {
                    key,
                    title: this.$tc(`__P__-design.designs.${key}`) + (isDefault ? ` (${this.$tc('__P__-design.default')})` : ''),
                };
            });
        },
    },

    created() {
        this.store.ensureLoaded();
        this.markerOff = window.ldAdminMarker?.onChange((active) => {
            this.markerActive = active;
        }) ?? null;
    },

    unmounted() {
        this.markerOff?.();
    },

    methods: {
        toggleMarker() {
            window.ldAdminMarker?.toggle();
        },

        async select(design) {
            if (design === this.current) {
                return;
            }

            try {
                await this.store.setDesign(design);
            } catch {
                // Anzeige ist schon umgeschaltet; nur das Speichern für den Benutzer ist fehlgeschlagen.
            }
        },
    },
};

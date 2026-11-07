import { DESIGNS } from '../../constants';

/**
 * Schalter „Design A | B | C“ für den Praxistest. Speichert die Wahl je Benutzer.
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
</div>`,

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
    },

    methods: {
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

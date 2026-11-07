import { CATEGORY_COLORS } from '../../constants';

/**
 * Kategorie-Chip. Aussehen je Design: A grau mit farbigem Icon,
 * B getönt mit Farbbalken (CMYK), C farbiges Quadrat.
 *
 * color: c1 | c2 | c3 | c4 (Kategorie-Farbe aus DESIGN.md)
 */
export default {
    template: `
<span
    class="__P__-chip"
    :style="{ '--__P__-t': 'var(--__P__-' + color + ')' }"
    :title="title"
>
    <mt-icon
        v-if="icon"
        class="__P__-chip__icon"
        :name="icon"
        size="12px"
    />
    <span class="__P__-chip__label">{{ label }}</span>
</span>`,

    props: {
        label: {
            type: String,
            required: true,
        },

        color: {
            type: String,
            required: false,
            default: 'c1',
            validator: (value) => CATEGORY_COLORS.includes(value),
        },

        icon: {
            type: String,
            required: false,
            default: null,
        },

        title: {
            type: String,
            required: false,
            default: null,
        },
    },
};

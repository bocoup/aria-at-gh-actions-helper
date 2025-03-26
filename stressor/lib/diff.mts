import { DiffOptions, DiffOptionsColor, diff as jestDiff } from 'jest-diff';

const noColor: DiffOptionsColor = string => string;
const options: DiffOptions = {
  aColor: noColor,
  bColor: noColor,
  changeColor: noColor,
  commonColor: noColor,
  patchColor: noColor
};

export default function diff(a: string | null, b: string | null): string {
  return jestDiff(a, b, options) || '';
}

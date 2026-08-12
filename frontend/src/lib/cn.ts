// Ghep class Tailwind co dieu kien, bo qua gia tri rong.
export function cn(
  ...classes: Array<string | false | null | undefined>
): string {
  return classes.filter(Boolean).join(" ");
}

const MS_PER_SECOND = 1000;
const SECONDS_PER_MINUTE = 60;

export default (duration: number): string => {
  const seconds = Math.floor((duration / MS_PER_SECOND) % SECONDS_PER_MINUTE);
  const minutes = Math.floor(duration / SECONDS_PER_MINUTE / MS_PER_SECOND);

  if (minutes === 0) {
    return `${seconds}s`;
  }
  return `${minutes}m${seconds}s`;
};

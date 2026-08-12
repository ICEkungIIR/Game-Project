// Ember particle field — respects prefers-reduced-motion
(function () {
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (reduceMotion) return;

  const field = document.getElementById('emberField');
  if (!field) return;

  const EMBER_COUNT = 22;

  for (let i = 0; i < EMBER_COUNT; i++) {
    const ember = document.createElement('span');
    const left = Math.random() * 100;
    const duration = 6 + Math.random() * 8;
    const delay = Math.random() * 10;
    const size = 2 + Math.random() * 3;

    ember.style.left = left + 'vw';
    ember.style.width = size + 'px';
    ember.style.height = size + 'px';
    ember.style.animationDuration = duration + 's';
    ember.style.animationDelay = delay + 's';

    field.appendChild(ember);
  }
})();

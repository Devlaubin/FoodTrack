/* ===== Shared JavaScript — FoodTrack ===== */

// --- Scroll Reveal ---
function initScrollReveal() {
    const revealElements = document.querySelectorAll('.reveal, .stagger-item');
    if (revealElements.length === 0) return;

    const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry, index) => {
            if (entry.isIntersecting) {
                // Add delay for staggered items
                const delay = entry.target.dataset.delay || 
                    (entry.target.classList.contains('stagger-item') ? 
                        Array.from(entry.target.parentElement.children).indexOf(entry.target) * 100 : 0);
                
                setTimeout(() => {
                    entry.target.classList.add('active');
                }, delay);
                
                observer.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.15,
        rootMargin: '0px 0px -50px 0px'
    });

    revealElements.forEach(el => observer.observe(el));
}

// --- Mobile Menu Toggle ---
function initMobileMenu() {
    const hamburger = document.getElementById('hamburger-btn');
    const mobileMenu = document.getElementById('mobile-menu');
    const body = document.body;

    if (!hamburger || !mobileMenu) return;

    hamburger.addEventListener('click', () => {
        const isOpen = mobileMenu.classList.contains('hidden');
        mobileMenu.classList.toggle('hidden');
        hamburger.innerHTML = isOpen ? 
            '<i class="fas fa-times text-2xl"></i>' : 
            '<i class="fas fa-bars text-2xl"></i>';
        body.classList.toggle('mobile-menu-open');
    });

    // Close on link click
    mobileMenu.querySelectorAll('a').forEach(link => {
        link.addEventListener('click', () => {
            mobileMenu.classList.add('hidden');
            hamburger.innerHTML = '<i class="fas fa-bars text-2xl"></i>';
            body.classList.remove('mobile-menu-open');
        });
    });
}

// --- Smooth scroll for anchor links ---
function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (href === '#') return;
            e.preventDefault();
            const target = document.querySelector(href);
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

// --- Count Up Animation ---
function initCountUp() {
    const counters = document.querySelectorAll('.count-up');
    if (counters.length === 0) return;

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const el = entry.target;
                const target = parseInt(el.dataset.target);
                const suffix = el.dataset.suffix || '';
                const duration = 2000;
                const start = performance.now();

                function update(currentTime) {
                    const elapsed = currentTime - start;
                    const progress = Math.min(elapsed / duration, 1);
                    // Ease out cubic
                    const eased = 1 - Math.pow(1 - progress, 3);
                    const current = Math.floor(eased * target);
                    el.textContent = current + suffix;
                    if (progress < 1) {
                        requestAnimationFrame(update);
                    }
                }
                requestAnimationFrame(update);
                observer.unobserve(el);
            }
        });
    }, { threshold: 0.5 });

    counters.forEach(c => observer.observe(c));
}

// --- Newsletter Form ---
function initNewsletter() {
    const form = document.getElementById('newsletter-form');
    if (!form) return;

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        const input = form.querySelector('input[type="email"]');
        const btn = form.querySelector('button');
        const originalText = btn.innerHTML;
        const email = input.value.trim();

        if (!email) return;

        // Loading state
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner"></span>';

        // Simulate API call
        await new Promise(resolve => setTimeout(resolve, 1500));

        // Success state
        btn.innerHTML = '✅ Inscrit !';
        btn.classList.remove('bg-ketchup');
        btn.classList.add('bg-pickle', 'text-white');
        input.value = '';

        setTimeout(() => {
            btn.innerHTML = originalText;
            btn.classList.remove('bg-pickle', 'text-white');
            btn.classList.add('bg-ketchup');
            btn.disabled = false;
        }, 3000);
    });
}

// --- Parallax effect on mouse move (for hero) ---
function initParallax() {
    const hero = document.querySelector('.parallax-container');
    if (!hero) return;

    hero.addEventListener('mousemove', (e) => {
        const rect = hero.getBoundingClientRect();
        const x = (e.clientX - rect.left) / rect.width - 0.5;
        const y = (e.clientY - rect.top) / rect.height - 0.5;

        hero.querySelectorAll('.parallax-layer').forEach((layer, i) => {
            const depth = (i + 1) * 10;
            const moveX = x * depth;
            const moveY = y * depth;
            layer.style.transform = `translate(${moveX}px, ${moveY}px)`;
        });
    });

    hero.addEventListener('mouseleave', () => {
        hero.querySelectorAll('.parallax-layer').forEach(layer => {
            layer.style.transform = 'translate(0, 0)';
        });
    });
}

// --- Initialize everything on DOM ready ---
document.addEventListener('DOMContentLoaded', () => {
    initScrollReveal();
    initMobileMenu();
    initSmoothScroll();
    initCountUp();
    initNewsletter();
    initParallax();
});


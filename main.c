// Test harness for COS284 Practical 3.
// Each assembly function is checked against a C reference implementation.
// Functions are declared weak, so tasks you haven't written yet are skipped
// instead of breaking the build.

#include <stdio.h>
#include <math.h>

typedef struct Book { int id; double rating; int pages; } Book;

long   total_pages(Book *books, long n)                      __attribute__((weak));
double average_rating(Book *books, long n)                   __attribute__((weak));
long   count_above(Book *books, long n, double threshold)    __attribute__((weak));
Book  *best_book(Book *books, long n)                        __attribute__((weak));
double weighted_rating(Book *books, long n)                  __attribute__((weak));

// ---- C reference implementations ----

static long ref_total_pages(Book *b, long n) {
    long s = 0;
    for (long i = 0; i < n; i++) s += b[i].pages;
    return s;
}

static double ref_average_rating(Book *b, long n) {
    double s = 0;
    for (long i = 0; i < n; i++) s += b[i].rating;
    return s / n;
}

static long ref_count_above(Book *b, long n, double t) {
    long c = 0;
    for (long i = 0; i < n; i++) if (b[i].rating > t) c++;
    return c;
}

static Book *ref_best_book(Book *b, long n) {
    Book *best = &b[0];
    for (long i = 1; i < n; i++) if (b[i].rating > best->rating) best = &b[i];
    return best;
}

static double ref_weighted_rating(Book *b, long n) {
    double num = 0, den = 0;
    for (long i = 0; i < n; i++) {
        num += b[i].rating * b[i].pages;
        den += b[i].pages;
    }
    return num / den;
}

// ---- test data ----

static Book sample[] = {
    {101, 4.5, 320},
    {102, 3.8, 150},
    {103, 4.9, 512},
    {104, 2.1,  90},
    {105, 4.0, 275},
};

// Two books share the top rating: best_book must return the FIRST (id 202).
static Book tie[] = {
    {201, 3.0, 100},
    {202, 4.7, 200},
    {203, 1.5,  50},
    {204, 4.7, 300},
};

static Book single[] = {
    {301, 3.3, 42},
};

// ---- checking ----

static int pass = 0, fail = 0, skip = 0;

static void report(const char *name, const char *set, int ok, const char *detail) {
    printf("%-4s  %-16s %-7s %s\n", ok ? "PASS" : "FAIL", name, set, detail);
    ok ? pass++ : fail++;
}

static int close_enough(double a, double b) {
    return fabs(a - b) <= 1e-9 * fmax(1.0, fabs(b));
}

static void run_set(const char *set, Book *b, long n, double threshold) {
    char buf[128];

    if (total_pages) {
        long got = total_pages(b, n), want = ref_total_pages(b, n);
        snprintf(buf, sizeof buf, "got %ld, want %ld", got, want);
        report("total_pages", set, got == want, buf);
    }
    if (average_rating) {
        double got = average_rating(b, n), want = ref_average_rating(b, n);
        snprintf(buf, sizeof buf, "got %.6f, want %.6f", got, want);
        report("average_rating", set, close_enough(got, want), buf);
    }
    if (count_above) {
        long got = count_above(b, n, threshold), want = ref_count_above(b, n, threshold);
        snprintf(buf, sizeof buf, "got %ld, want %ld (threshold %.1f)", got, want, threshold);
        report("count_above", set, got == want, buf);
    }
    if (best_book) {
        Book *got = best_book(b, n), *want = ref_best_book(b, n);
        if (got >= b && got < b + n)
            snprintf(buf, sizeof buf, "got id %d, want id %d", got->id, want->id);
        else
            snprintf(buf, sizeof buf, "got %p (outside the array!), want id %d", (void *)got, want->id);
        report("best_book", set, got == want, buf);
    }
    if (weighted_rating) {
        double got = weighted_rating(b, n), want = ref_weighted_rating(b, n);
        snprintf(buf, sizeof buf, "got %.6f, want %.6f", got, want);
        report("weighted_rating", set, close_enough(got, want), buf);
    }
}

int main(void) {
    const char *names[] = {"total_pages", "average_rating", "count_above", "best_book", "weighted_rating"};
    void *fns[] = {(void *)total_pages, (void *)average_rating, (void *)count_above,
                   (void *)best_book, (void *)weighted_rating};
    for (int i = 0; i < 5; i++)
        if (!fns[i]) { printf("SKIP  %-16s (task%d.asm not written yet)\n", names[i], i + 1); skip++; }

    run_set("sample", sample, sizeof sample / sizeof *sample, 4.0);  // 4.0 is exactly one rating: must not count
    run_set("tie",    tie,    sizeof tie    / sizeof *tie,    4.7);  // threshold equal to the max: count is 0
    run_set("single", single, 1,                               3.0);

    printf("\n%d passed, %d failed, %d tasks skipped\n", pass, fail, skip);
    return fail != 0;
}

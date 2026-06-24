// ASan trip-wire: heap-buffer-overflow.
// Expected: AddressSanitizer reports "heap-buffer-overflow".

auto main(int argc, char ** /*argv*/) -> int {
	int *a = new int[3];
	a[argc + 2] = 7; // argc >= 1 -> index >= 3 -> out of bounds (size 3, valid 0..2)
	int r = a[0];
	delete[] a;
	return r;
}

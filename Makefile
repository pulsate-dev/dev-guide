setup:
	cargo install mdbook mdbook-toc mdbook-alerts

b:
	mdbook build

bo:
	mdbook build --open

d:
	mdbook serve

c:
	mdbook clean

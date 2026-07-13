# Download bundled font files from Google Fonts
#
# This script documents how the font files in inst/fonts/ were obtained.
# Run it to refresh or update the bundled fonts.
#
# Only Inter is bundled (the sole free font in Insper's 2026 brand kit).
# It is licensed under the SIL Open Font License 1.1.
# See inst/fonts/OFL.txt for the full license text.

library(systemfonts)

pkg_dir <- here::here()
font_dir <- file.path(pkg_dir, "inst", "fonts")

dir.create(file.path(font_dir, "inter"), showWarnings = FALSE, recursive = TRUE)

tmpdir <- tempdir()

# Download from Google Fonts ----
message("Downloading Inter...")
get_from_google_fonts("Inter", dir = file.path(tmpdir, "inter"))

# Copy only the weights we need (Regular, Bold, Italic, BoldItalic) ----

# Inter (sans-serif, body text)
file.copy(
  file.path(tmpdir, "inter", "Inter-regular.ttf"),
  file.path(font_dir, "inter", "Inter-Regular.ttf"),
  overwrite = TRUE
)
file.copy(
  file.path(tmpdir, "inter", "Inter-700.ttf"),
  file.path(font_dir, "inter", "Inter-Bold.ttf"),
  overwrite = TRUE
)
file.copy(
  file.path(tmpdir, "inter", "Inter-italic.ttf"),
  file.path(font_dir, "inter", "Inter-Italic.ttf"),
  overwrite = TRUE
)
file.copy(
  file.path(tmpdir, "inter", "Inter-700italic.ttf"),
  file.path(font_dir, "inter", "Inter-BoldItalic.ttf"),
  overwrite = TRUE
)

# Subset to Latin glyphs ----
# Strips Cyrillic, Greek, Vietnamese, etc. to reduce package size (~50% smaller).
# Requires Python fonttools: pip3 install fonttools
message("Subsetting fonts to Latin glyphs...")
subset_script <- tempfile(fileext = ".py")
writeLines(
  '
import os, glob, sys
from fontTools.subset import Subsetter, Options, load_font, save_font

font_dir = sys.argv[1]
keep = set()
for r in [range(0x0000,0x0250), range(0x2000,0x2070), range(0x2070,0x20A0),
          range(0x20A0,0x20D0), range(0x2100,0x2150), range(0x2150,0x2190),
          range(0x2200,0x2300), range(0x25A0,0x2600), range(0x2600,0x2700),
          range(0xFB00,0xFB07)]:
    keep.update(r)

for ttf in sorted(glob.glob(os.path.join(font_dir, "**/*.ttf"), recursive=True)):
    old = os.path.getsize(ttf)
    opts = Options()
    opts.layout_features = ["*"]
    opts.name_IDs = ["*"]
    opts.notdef_outline = True
    opts.hinting = False
    opts.desubroutinize = True
    font = load_font(ttf, opts)
    sub = Subsetter(options=opts)
    sub.populate(unicodes=keep)
    sub.subset(font)
    save_font(font, ttf, opts)
    font.close()
    new = os.path.getsize(ttf)
    print(f"  {os.path.basename(ttf)}: {old//1024}KB -> {new//1024}KB ({100*(1-new/old):.0f}% smaller)")
',
  subset_script
)
system2("python3", args = c(subset_script, font_dir))

# Report ----
files <- list.files(
  font_dir,
  pattern = "\\.ttf$",
  recursive = TRUE,
  full.names = TRUE
)
sizes <- file.info(files)$size
for (i in seq_along(files)) {
  message(sprintf("  %s  (%s KB)", basename(files[i]), round(sizes[i] / 1024)))
}
message(sprintf(
  "\nTotal: %s KB (%s files)",
  round(sum(sizes) / 1024),
  length(files)
))

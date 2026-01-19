#!/usr/bin/env node
/**
 * Generate PDF from markdown-cv using Puppeteer
 * Uses existing Chromium installation (puppeteer-core)
 *
 * Usage:
 *   node generate-pdf.js                    # Generate both PDFs
 *   node generate-pdf.js descriptive        # Generate descriptive CV only
 *   node generate-pdf.js concise            # Generate concise CV only
 *   node generate-pdf.js <url> <output>     # Legacy: custom URL and output
 */

const puppeteer = require('puppeteer-core');
const path = require('path');

const CHROMIUM_PATH = '/Applications/Chromium.app/Contents/MacOS/Chromium';
const BASE_URL = 'http://localhost:4001';

// CV configurations
const CV_CONFIGS = {
  descriptive: {
    url: `${BASE_URL}/`,  // index.md serves the descriptive CV
    output: 'GillMichelle_DescriptiveCV.pdf',
    title: 'Descriptive CV',
  },
  concise: {
    url: `${BASE_URL}/concise.html`,
    output: 'GillMichelle_ConciseCV.pdf',
    title: 'Concise CV',
  },
};

/**
 * Generate a footer template for the given CV type
 * @param {string} cvTitle - The CV title (e.g., "Descriptive CV" or "Concise CV")
 * @returns {string} HTML footer template
 */
function getFooterTemplate(cvTitle) {
  const now = new Date();
  const preparedDate = `Prepared ${String(now.getMonth() + 1).padStart(2, '0')}/${String(now.getDate()).padStart(2, '0')}/${now.getFullYear()}`;

  return `
    <div style="font-family: Avenir, Verdana, sans-serif; font-size: 9px;
                color: #666; width: 100%; padding: 0 0.5in;
                display: flex; justify-content: space-between;">
      <span>Michelle Lynn Gill &middot; ${cvTitle}</span>
      <span>Page <span class="pageNumber"></span> of <span class="totalPages"></span></span>
      <span>${preparedDate}</span>
    </div>
  `;
}

/**
 * Generate a PDF from a URL
 * @param {string} url - The URL to generate PDF from
 * @param {string} outputPath - The output file path
 * @param {string} cvTitle - The CV title for the footer
 */
async function generatePDF(url, outputPath, cvTitle) {
  const browser = await puppeteer.launch({
    executablePath: CHROMIUM_PATH,
    headless: true,
  });

  const page = await browser.newPage();
  await page.goto(url, { waitUntil: 'networkidle0' });

  await page.pdf({
    path: outputPath,
    format: 'Letter',
    printBackground: true,
    margin: {
      top: '0.5in',
      right: '0.5in',
      bottom: '0.75in',
      left: '0.5in',
    },
    displayHeaderFooter: true,
    headerTemplate: '<div></div>',
    footerTemplate: getFooterTemplate(cvTitle),
  });

  await browser.close();
  console.log(`PDF saved to: ${outputPath}`);
}

/**
 * Generate a single CV PDF by type
 * @param {string} type - The CV type ('descriptive' or 'concise')
 */
async function generateCV(type) {
  const config = CV_CONFIGS[type];
  if (!config) {
    console.error(`Unknown CV type: ${type}`);
    process.exit(1);
  }

  const outputPath = path.join(__dirname, config.output);
  await generatePDF(config.url, outputPath, config.title);
}

/**
 * Generate both CV PDFs
 */
async function generateAllCVs() {
  for (const type of Object.keys(CV_CONFIGS)) {
    await generateCV(type);
  }
}

// CLI
async function main() {
  const arg = process.argv[2];

  if (!arg) {
    // No argument: generate both
    await generateAllCVs();
  } else if (arg === 'descriptive' || arg === 'concise') {
    // Single CV type
    await generateCV(arg);
  } else if (arg.startsWith('http')) {
    // Legacy mode: custom URL and output
    const url = arg;
    const output = process.argv[3] || path.join(__dirname, 'GillMichelle_CV.pdf');
    await generatePDF(url, output, 'CV');
  } else {
    console.error('Usage:');
    console.error('  node generate-pdf.js                    # Generate both PDFs');
    console.error('  node generate-pdf.js descriptive        # Generate descriptive CV only');
    console.error('  node generate-pdf.js concise            # Generate concise CV only');
    console.error('  node generate-pdf.js <url> <output>     # Legacy: custom URL and output');
    process.exit(1);
  }
}

main().catch(console.error);

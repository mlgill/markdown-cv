#!/usr/bin/env node
/**
 * Generate PDF from markdown-cv using Puppeteer
 * Uses existing Chromium installation (puppeteer-core)
 *
 * Usage: node generate-pdf.js [url] [output]
 * Default: node generate-pdf.js http://localhost:4001 GillMichelle_CV.pdf
 */

const puppeteer = require('puppeteer-core');
const path = require('path');

const CHROMIUM_PATH = '/Applications/Chromium.app/Contents/MacOS/Chromium';

async function generatePDF(url, outputPath) {
  const browser = await puppeteer.launch({
    executablePath: CHROMIUM_PATH,
    headless: true,
  });

  const page = await browser.newPage();
  await page.goto(url, { waitUntil: 'networkidle0' });

  await page.pdf({
    path: outputPath,
    format: 'Letter',           // or 'A4'
    printBackground: true,      // include background colors/images
    margin: {
      top: '0.5in',
      right: '0.5in',
      bottom: '0.75in',
      left: '0.5in',
    },
    // Header/footer options
    displayHeaderFooter: true,

    // Empty header (or customize with same font as CV)
    headerTemplate: '<div></div>',

    // Footer with page numbers using CV's font (Avenir)
    // - Includes generation date
    footerTemplate: `
      <div style="font-family: Avenir, Verdana, sans-serif; font-size: 9px;
                  color: #666; width: 100%; padding: 0 0.5in;
                  display: flex; justify-content: space-between;">
        <span>Michelle Lynn Gill &middot; Prepared ${new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}</span>
        <span>Page <span class="pageNumber"></span> of <span class="totalPages"></span></span>
      </div>
    `,

    // Alternative: no header/footer at all
    // displayHeaderFooter: false,
  });

  await browser.close();
  console.log(`PDF saved to: ${outputPath}`);
}

// CLI
const url = process.argv[2] || 'http://localhost:4001';
const output = process.argv[3] || path.join(__dirname, 'GillMichelle_CV.pdf');

generatePDF(url, output).catch(console.error);

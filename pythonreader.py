import numpy as np
from PIL import ImageGrab, Image
import pytesseract
from PIL import Image, ImageEnhance, ImageFilter
from textblob import TextBlob
import time
from PyPDF2 import PdfReader, PdfWriter

for i in range(0,94):
    reader = PdfReader('/Users/lukastaylor/combine.pdf')
    number_of_pages = len(reader.pages)
    page = reader.pages[pageno]
    text = page.extract_text()
    pdftextlist = text.split(sep=None, maxsplit=-1)
    pdftextlist = pdftextlist[100:]

def readerfunc(pageno):

    reader = PdfReader('/Users/lukastaylor/combine.pdf')
    number_of_pages = len(reader.pages)
    page = reader.pages[pageno]
    text = page.extract_text()
    pdftextlist = text.split(sep=None, maxsplit=-1)
    pdftextlist = pdftextlist[100:]
    return pdftextlist

whiletrueiteration = 0

starttime = time.time()

while True:
    # Code executed here
    # Grab some screen
    screen =  ImageGrab.grab(bbox=(0,0,800,640))
    #screen = Image.open('/Users/lukastaylor/example.png')

    # Make greyscale
    w = screen.convert('L')

    # Save so we can see what we grabbed
    w.save('grabbed.png')

    text = pytesseract.image_to_string(w)
    correctedText = TextBlob(text).correct()

    #print(correctedText)

    correctedtextlist = correctedText.split(sep=None, maxsplit=-1)
    #print(correctedtextlist)

    pagehits = {}
    for i in range(0,94):
        pagehits[i] = len(set(correctedtextlist) & set(readerfunc(i)))

    #print(pagehits)

    inverse = [(value, key) for key, value in pagehits.items()]
    #print(max(inverse)[1])
    maxinverse = max(inverse)[1]

    reader = PdfReader('/Users/lukastaylor/combine.pdf')

    pdf_file_path = 'Unknown.pdf'
    file_base_name = pdf_file_path.replace('.pdf', '')

    pdfWriter = PdfWriter()

    pdfWriter.add_page(reader.pages[maxinverse]) #off by one error?

    with open('{0}_subset.pdf'.format(file_base_name), 'wb') as f:
        pdfWriter.write(f)
        f.close()

    #time.sleep(4.0 - ((time.time() - starttime) % 4.0))

    whiletrueiteration += 1

    print("Iteration", whiletrueiteration)

    if whiletrueiteration > 5: #failsafe
        break
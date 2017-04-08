using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace InvoiceManager
{
    public partial class DataExtract : System.Web.UI.Page
    {
        static string applicationPath, invoiceDataFolderPath;
        static List<InvoiceDataInfo> invoiceDataList = new List<InvoiceDataInfo>();

        protected void Page_Load(object sender, EventArgs e)
        {
            applicationPath = AppDomain.CurrentDomain.BaseDirectory;
            invoiceDataFolderPath = @"data\invoice\";
        }

        [WebMethod]
        public static string GetInvoiceDataInfoList()
        {
            invoiceDataList.Clear();
            string[] imageFileList = Directory.GetFiles(applicationPath + invoiceDataFolderPath, "*.png");
            string fileListString = "";
            for(int i = 0; i < imageFileList.Length; i++)
            {
                GC.Collect();
                Bitmap bitmap = new Bitmap(imageFileList[i]);
                InvoiceDataInfo invoiceData = new InvoiceDataInfo();
                invoiceData.fileName = Path.GetFileNameWithoutExtension(imageFileList[i]);
                invoiceData.imageFilePath = string.Format(@"{0}{1}.png", invoiceDataFolderPath, invoiceData.fileName);
                invoiceData.textFilePath = string.Format(@"{0}{1}{2}.txt", applicationPath, invoiceDataFolderPath, invoiceData.fileName);
                invoiceData.imageWidth = bitmap.Width;
                invoiceData.imageHeight = bitmap.Height;
                invoiceDataList.Add(invoiceData);
                fileListString += (i == 0 ? "" : "|") + invoiceData.fileName;
            }
            return fileListString;
        }

        [WebMethod]
        public static string GetInvoiceDataInfo(int invoiceNo)
        {
            if (invoiceNo >= invoiceDataList.Count) return "ERROR";
            return string.Format("{0}|{1}|{2}", invoiceDataList[invoiceNo].imageFilePath, invoiceDataList[invoiceNo].imageWidth, invoiceDataList[invoiceNo].imageHeight);
        }

        [WebMethod]
        public static string GetInvoiceDataForRect(int invoiceNo, int X1, int Y1, int X2, int Y2)
        {
            if (invoiceNo >= invoiceDataList.Count) return "Invoice No Error";
            int x = Math.Min(X1, X2);
            int y = Math.Min(Y1, Y2);
            int w = Math.Abs(X1 - X2);
            int h = Math.Abs(Y1 - Y2);
            string wordListInRect = "";
            int wordCount = 0;
            try
            {
                StreamReader sr = new StreamReader(invoiceDataList[invoiceNo].textFilePath);
                while (true)
                {
                    string line = sr.ReadLine();
                    OcrWord ocrWord = new OcrWord();
                    if (sr.EndOfStream || !ocrWord.readFromLine(line)) break;
                    if (ocrWord.intersects(x, y, w, h))
                    {
                        wordListInRect += ocrWord.toString() + "\r\n";
                        wordCount++;
                    }
                }
                return string.Format("Count = {0}\r\n{1}", wordCount, wordListInRect);
            }
            catch
            {
                return "Text File Read Error";
            }
        }

        [WebMethod]
        public static string GetInvoiceLineItemDataForRect(int invoiceNo, int X1, int Y1, int X2, int Y2)
        {
            if (invoiceNo >= invoiceDataList.Count) return "Invoice No Error";
            List<OcrWord> ocrWordList = new List<OcrWord>();
            int x = Math.Min(X1, X2);
            int y = Math.Min(Y1, Y2);
            int w = Math.Abs(X1 - X2);
            int h = Math.Abs(Y1 - Y2);
            string wordListInRect = "";
            int wordCount = 0;
            try
            {
                StreamReader sr = new StreamReader(invoiceDataList[invoiceNo].textFilePath);
                while (true)
                {
                    string line = sr.ReadLine();
                    OcrWord ocrWord = new OcrWord();
                    if (sr.EndOfStream || !ocrWord.readFromLine(line)) break;
                    ocrWordList.Add(ocrWord);
                }
                bool ok = true;
                int lineSpace = 0;
                while (ok)
                {
                    ok = false;
                    for(int i = 0; i < ocrWordList.Count; i++)
                    {
                        if (ocrWordList[i].intersects(x, y, w, h + lineSpace))
                        {
                            wordListInRect += ocrWordList[i].toString() + "\r\n";
                            wordCount++;
                            ok = true;
                            ocrWordList.RemoveAt(i);
                            i--;
                        }
                    }
                    y += h + lineSpace;
                    lineSpace = h;
                }
                return string.Format("Count = {0}\r\n{1}", wordCount, wordListInRect);
            }
            catch
            {
                return "Text File Read Error";
            }
        }
    }

    class InvoiceDataInfo
    {
        public string fileName, imageFilePath, textFilePath;
        public int imageWidth, imageHeight;
    }

    class OcrWord
    {
        public int X { get; set; }
        public int Y { get; set; }
        public int W { get; set; }
        public int H { get; set; }
        public string Word { get; set; }

        public OcrWord()
        {
            X = Y = W = H = 0;
            Word = "";
        }

        public bool readFromLine(string line)
        {
            if (line.Length == 0) return false;
            string[] partSeparatingChars = { "--->" };
            char[] wordSeparatingChars = { ' ' };
            string[] parts = line.Split(partSeparatingChars, StringSplitOptions.RemoveEmptyEntries);
            string[] words = parts[0].Split(wordSeparatingChars, StringSplitOptions.RemoveEmptyEntries);
            try
            {
                X = int.Parse(words[0]);
                Y = int.Parse(words[1]);
                W = int.Parse(words[2]);
                H = int.Parse(words[3]);
                Word = parts[1].Trim();
                return true;
            }
            catch
            {
                return false;
            }
        }

        public bool intersects(int x,int y,int w,int h)
        {
            Rectangle r1 = new Rectangle(X, Y, W, H);
            Rectangle r2 = new Rectangle(x, y, w, h);
            return r1.IntersectsWith(r2);
        }

        public string toString()
        {
            return string.Format("{0} [ {1} , {2} , {3} , {4} ]", Word, X, Y, W, H);
        }
    }
}

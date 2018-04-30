import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

//
// Model conditions are as follows:
//
// java DataProcessor noscale.100g.500b  > noscale.100g.500b.csv
// java DataProcessor noscale.200g.1000b > noscale.200g.1000b.csv
// java DataProcessor noscale.200g.250b  > noscale.200g.250b.csv
// java DataProcessor noscale.200g.500b  > noscale.200g.500b.csv
// java DataProcessor noscale.200g.true  > noscale.200g.true.csv
// java DataProcessor noscale.400g.500b  > noscale.400g.500b.csv
// java DataProcessor noscale.50g.500b   >  noscale.50g.500b.csv
// java DataProcessor noscale.800g.500b  >  noscale.800g.500b.csv
// java DataProcessor scale2d.200g.500b  >  scale2d.200g.500b.csv
// java DataProcessor scale2u.200g.500b  >  scale2u.200g.500b.csv
// java DataProcessor scale5d.200g.500b  >  scale5d.200g.500b.csv


class Replicate {
    int astralQS;
    int mrlQS;
    int qfmQS;

    int qfmBestInd;

    double astralFN;
    double mrlFN;
    double qfmFN;

    public String toString() {
        return "" +
               mrlQS    + "," + mrlFN    + "," +
               astralQS + "," + astralFN + "," +
               qfmQS    + "," + qfmFN    ;
    }
}

public class DataProcessor {

    final static int MAX_REPLICATES = 20;
    final static int MAX_ITER = 2;

    static Replicate[] _replicate = new Replicate[MAX_REPLICATES];
    static int _nReplicates = 0;

    public static void main(String[] args) {
        // write your code here

        String strQSFile;
        String strFnFile;
        String strLine;

        int i;

        // Instantiate the items of replicate array
        for (i = 0; i < _replicate.length; i++) {
            _replicate[i] = new Replicate();
        }

        if (args.length < 1) {
            System.out.println("Usage: java DataProcessor <model condition>");
            return;
        }

        strQSFile = "qs_" + args[0] + ".txt";
        strFnFile = "fn_" + args[0] + ".txt";

        try (
                BufferedReader qsReader = new BufferedReader(new FileReader(strQSFile));
                BufferedReader fnReader = new BufferedReader(new FileReader(strFnFile));
        ) {
            while (null != qsReader.readLine()) {
                // Ignore the replicate id and header
                qsReader.readLine();

                // Get the quartet score of the MRL guide tree
                strLine = qsReader.readLine();
                _replicate[_nReplicates].mrlQS = Integer.parseInt(strLine.split(",")[1]);

                _replicate[_nReplicates].qfmQS = 0;
                _replicate[_nReplicates].qfmBestInd = 0;
                for (i = 0; i < 5; i++) {
                    strLine = qsReader.readLine();

                    int t = Integer.parseInt(strLine.split(",")[1]);
                    if (i < MAX_ITER && t > _replicate[_nReplicates].qfmQS) {
                        _replicate[_nReplicates].qfmQS = t;
                        _replicate[_nReplicates].qfmBestInd = i;
                    }
                }

                // Ignore the header before ASTRAL score
                qsReader.readLine();

                strLine = qsReader.readLine();
                _replicate[_nReplicates].astralQS = Integer.parseInt(strLine.split(",")[1]);

                _nReplicates++;
            }

            _nReplicates = 0;
            while (null != fnReader.readLine()) {
                // Ignore the replicate id and header
                fnReader.readLine();

                // Get the quartet score of the MRL guide tree
                strLine = fnReader.readLine();
                _replicate[_nReplicates].mrlFN = Double.parseDouble(strLine.split(",")[2]);

                for (i = 0; i < 5; i++) {
                    strLine = fnReader.readLine();
                    if (_replicate[_nReplicates].qfmBestInd == i) {
                        _replicate[_nReplicates].qfmFN = Double.parseDouble(strLine.split(",")[2]);
                    }
                }

                strLine = fnReader.readLine();
                _replicate[_nReplicates].astralFN = Double.parseDouble(strLine.split(",")[2]);

                _nReplicates++;
            }

            System.out.println("R_ID,MRL_QS,MRL_FN,ASTRAL_QS,ASTRAL_FN,QFM_QS,QFM_FN");
            for (i = 0; i < _nReplicates; i++) {
                System.out.println("" + (i+1) + "," + _replicate[i]);
            }
        } catch (IOException e) {
            System.out.println(e);
        }
    }
}

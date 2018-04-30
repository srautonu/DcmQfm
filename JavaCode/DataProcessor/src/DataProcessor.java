import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class DataProcessor {

    final static int MAX_REPLICATES = 20;
    final static int MAX_DCM_ITER = 5;

    static int[] _astralQS = new int[MAX_REPLICATES];
    static int[] _qfmQS = new int[MAX_REPLICATES];
    static int[] _mrlQS = new int[MAX_REPLICATES];
    static int _nReplicates = 0;


    public static void main(String[] args) {
	    // write your code here

        String strQSFile;
        String strFnFile;
        String strLine;

        int i;

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
            while (true) {
                // Ignore the replicate id and header
                qsReader.readLine();
                qsReader.readLine();

                // Get the quartet score of the MRL guide tree
                strLine = qsReader.readLine();
                _mrlQS[_nReplicates] = Integer.parseInt(strLine.split(",")[1]);

                for (i = 1; i <= 5; i++) {
                    strLine = qsReader.readLine();
                    // TODO: Process and store the score
                }

                // Ignore the header before ASTRAL score
                qsReader.readLine();

                strLine = qsReader.readLine();
                _astralQS[_nReplicates] = Integer.parseInt(strLine.split(",")[1]);


                _nReplicates++;


            }


        } catch (IOException e) {
            System.out.println(e);
        }


    }
}

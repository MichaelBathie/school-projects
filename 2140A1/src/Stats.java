import java.lang.Math;

public class Stats {
	/*
	 * Creates a mean based from a passed array
	 */
	public static double mean(long data[]) {
		double sum = 0;
		for (int i = 0; i < data.length; i++)
			sum += data[i];
		return sum / (double)data.length;
	}
	
	/*
	 * Creates a standard deviation from a passed array
	 */
	public static double standardDeviation(long data[]) {
		double mean = mean(data);
		
		double summation = 0;
		for (int i = 0; i < data.length; i++) {
			summation += Math.pow(data[i] - mean, 2);
		}
		return Math.sqrt(1/(double)data.length * summation);
	}
	
	/*
	 * Return a z-statistic, difference, reported in standard deviations
	 */
	public static double zTest(long left[], long right[]) {
		return (mean(left) - mean(right))/
				Math.sqrt(Math.pow(standardDeviation(left),2) + Math.pow(standardDeviation(right),2));
	}
}

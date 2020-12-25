import java.util.Scanner;

public class day25 {

    static int modPow(int base, int exp, int mod) {
        long x = 1;
        while (exp > 0) {
            x = (x * base) % mod;
            --exp;
        }
        return (int)x;
    }

    static int solve(int base, int mod, int target) {
        long x = 1;
        int i = 0;
        while (x != target) {
            x = (base * x) % mod;
            ++i;
        }
        return i;
    }

    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        int card = in.nextInt();
        int door = in.nextInt();
        in.close();

        int exp = solve(7, 20201227, card);
        int answer = modPow(door, exp, 20201227);
        System.out.println(answer);
    }
}

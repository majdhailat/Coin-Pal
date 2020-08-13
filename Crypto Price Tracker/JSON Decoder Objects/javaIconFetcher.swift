/*
 import java.io.*;
 import java.net.URL;

 public class Main {
     private static String[] tickers = new String[]{"BTC", "ETH", "USDT", "XRP", "BCH", "BSV", "LTC", "BNB", "EOS", "XTZ", "ADA", "LINK", "XLM", "LEO", "XMR", "TRX", "HT", "ETC", "NEO", "DASH", "USDC", "ATOM", "MIOTA", "ZEC", "XEM", "ONT", "MKR", "DOGE", "BAT", "OMG", "VET", "PAX", "DGB", "ZRX", "THETA", "ICX", "QTUM", "DCR", "BTG", "ALGO", "LSK", "ENJ", "REP", "TUSD", "NANO", "DAI", "KNC", "RVN", "MONA", "WAVES", "ZIL", "BCD", "SC", "SNT", "UBT", "DX", "MCO", "HOT", "STEEM", "NRG", "KMD", "CKB", "BTM", "HC", "ABBC", "LEND", "SEELE", "NEXO", "NMR", "ETN", "XVG", "REN", "QNT", "BTS", "MANA", "LUNA", "ARDR", "GNT", "WAXP", "DATA", "IOST", "ZEN", "ELF", "VSYS", "XZC", "MAID", "PAXG", "LRC", "RCN", "POWR", "AE", "AION", "CRPT", "ANT", "GXC", "STRAT", "WICC", "NPXS", "RLC", "TOMO"};
     private static String[] IDs = new String[]{"bitcoin", "ethereum", "tether", "ripple", "bitcoin-cash", "bitcoin-sv", "litecoin", "binance-coin", "eos", "tezos", "cardano", "chainlink", "stellar", "unus-sed-leo", "monero", "tron", "huobi-token", "ethereum-classic", "neo", "dash", "usd-coin", "cosmos", "iota", "zcash", "nem", "ontology", "maker", "dogecoin", "basic-attention-token", "omisego", "vechain", "paxos-standard-token", "digibyte", "0x", "theta-token", "icon", "qtum", "decred", "bitcoin-gold", "algorand", "lisk", "enjin-coin", "augur", "trueusd", "nano", "multi-collateral-dai", "ravencoin", "kyber-network", "monacoin", "waves", "zilliqa", "bitcoin-diamond", "siacoin", "status", "dxchain-token", "crypto-com", "holo", "unibright", "steem", "energi", "komodo", "nervos-network", "bytom", "abbc-coin", "hypercash", "ethlend", "seele", "nexo", "numeraire", "electroneum", "republic-protocol", "quant", "verge", "bitshares", "decentraland", "terra-luna", "ardor", "golem-network-tokens", "wax", "iostoken", "streamr-datacoin", "zencash", "v-systems", "aelf", "zcoin", "maidsafecoin", "pax-gold", "loopring", "ripio-credit-network", "power-ledger", "aeternity", "aion", "crypterium", "aragon", "gxchain", "stratis", "waykichain", "pundi-x", "rlc", "tomochain"};

     public static void main (String []args) throws IOException {
         for (int i = 0; i < tickers.length; i++) {
             String tick = tickers[i];
             tick = tick.toLowerCase();
             try {
                 saveImage("https://cryptoicons.org/api/icon/" + tick + "/512", IDs[i]);
             }catch (FileNotFoundException ignored){

             }
         }
     }

     public static void saveImage(String imageUrl, String coinName) throws IOException {
         URL url = new URL(imageUrl);
         String destName = "figures/"+coinName+".png";
         System.out.println(destName);

         InputStream is = url.openStream();
         OutputStream os = new FileOutputStream(destName);

         byte[] b = new byte[2048];
         int length;

         while ((length = is.read(b)) != -1) {
             os.write(b, 0, length);
         }

         is.close();
         os.close();
     }
 }
 */

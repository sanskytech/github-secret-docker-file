export default function Home() {
  console.log(process.env.NEXT_PUBLIC_MY_SECRET);
  return (
    <main>
      <center>
        <h1>My Secret: {process.env.NEXT_PUBLIC_MY_SECRET}</h1>
      </center>
    </main>
  );
}

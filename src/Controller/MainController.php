<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpClient\HttpClient;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Throwable;

class MainController extends AbstractController {

    /**
     * @Route("/", name="main")
     */
    public function index(): Response
    {
        $client = HttpClient::createForBaseUri(
            $this->getParameter("api_url")
        );

        try {
            $data = $client->request("GET", "")->toArray();
        } catch (Throwable $e) {
            $data = ["error" => $e->getMessage()];
        }

        return $this->render('main.html.twig', $data);
    }
}